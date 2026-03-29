/**
 * HTTPS chatbot (figure & mô hình): POST { messages: [{ role, content }] }
 * — CORS: xử lý trong code (applyCors) cho https://figurestore-68028.web.app & firebaseapp.com
 * — Secret: firebase functions:secrets:set GEMINI_API_KEY
 * — Deploy: firebase deploy --only functions:productChatbot
 *   (firebase-functions@4.x: tương thích Firebase CLI cũ; nếu vẫn lỗi,
 *    cài CLI mới: npm i -g firebase-tools@latest — cần >=13.16 với firebase-functions v5+)
 * — Flutter: --dart-define=PRODUCT_CHATBOT_URL=https://<region>-<project>.cloudfunctions.net/productChatbot
 *
 * PayOS:
 * — Secrets: PAYOS_CLIENT_ID, PAYOS_API_KEY, PAYOS_CHECKSUM_KEY (functions:secrets:set)
 * — POST payosCreatePaymentLink: { orderId }, Bearer Firebase ID token
 * — payosWebhook: URL đăng ký trên PayOS; invoker public
 * — Deploy: firebase deploy --only functions:payosCreatePaymentLink,functions:payosWebhook
 * — Tạo link: REST + HMAC; credential: Secret → env PAYOS_* → key demo (như pharma local-server).
 * — Production: set secrets, không phụ thuộc key demo trong code.
 */
const {onRequest} = require("firebase-functions/v2/https");
const {setGlobalOptions} = require("firebase-functions/v2");
const {defineSecret} = require("firebase-functions/params");
const crypto = require("crypto");
const admin = require("firebase-admin");
const {GoogleGenerativeAI} = require("@google/generative-ai");
const {PayOS, APIError} = require("@payos/node");

setGlobalOptions({maxInstances: 10, region: "asia-southeast1"});

const geminiApiKey = defineSecret("GEMINI_API_KEY");

const payosClientId = defineSecret("PAYOS_CLIENT_ID");
const payosApiKeySecret = defineSecret("PAYOS_API_KEY");
const payosChecksumKey = defineSecret("PAYOS_CHECKSUM_KEY");

/** Return / cancel URL cho PayOS (Flutter web). */
const PAYOS_APP_ORIGIN = "https://figurestore-68028.web.app";

const PAYOS_MERCHANT_API = "https://api-merchant.payos.vn";

const PAYOS_DEFAULT_CLIENT_ID = "f746466b-5ff5-4f91-b85b-52c95f7d4b39";
const PAYOS_DEFAULT_API_KEY = "b4aacd22-57d5-4e21-93d1-5468e6590953";
const PAYOS_DEFAULT_CHECKSUM_KEY =
  "9ced6497bf538549862baf16d57212f0e3009d84911f6982c6b5a81f9dbbd2ca";

if (!admin.apps.length) {
  admin.initializeApp();
}

const MAX_HISTORY = 18;
const MAX_CANDIDATES = 80;
const DEFAULT_PRICE_MAX = 500000000;

/** Origins được phép gọi từ trình duyệt (Flutter web). Bổ sung khi có domain tùy chỉnh. */
const ALLOWED_BROWSER_ORIGINS = new Set([
  "https://figurestore-68028.web.app",
  "https://figurestore-68028.firebaseapp.com",
]);

/** Cho phép Flutter web debug: localhost / 127.0.0.1 bất kỳ cổng */
function isLocalDevOrigin(origin) {
  if (!origin || typeof origin !== "string") return false;
  return /^http:\/\/localhost(:\d+)?$/.test(origin) ||
    /^http:\/\/127\.0\.0\.1:\d+$/.test(origin);
}

/**
 * CORS cho Hosting + localhost. Gen2 `cors: true` đôi khi thiếu header preflight từ web.app.
 */
function applyCors(req, res) {
  const origin = req.headers.origin;
  if (origin && (ALLOWED_BROWSER_ORIGINS.has(origin) || isLocalDevOrigin(origin))) {
    res.setHeader("Access-Control-Allow-Origin", origin);
    res.setHeader("Vary", "Origin");
  }
  res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
  res.setHeader(
      "Access-Control-Allow-Headers",
      "Content-Type, Authorization, X-Requested-With",
  );
  res.setHeader("Access-Control-Max-Age", "86400");
}

function parseNumberVi(s) {
  return parseFloat(String(s).replace(",", ".")) || 0;
}

/**
 * Heuristic budget from recent user turns (VND).
 */
function inferBudgetFromMessages(messages) {
  const userText = messages
      .filter((m) => m.role === "user")
      .map((m) => String(m.content || ""))
      .join(" ");
  let min = 0;
  let max = DEFAULT_PRICE_MAX;
  let explicit = false;
  const t = userText.toLowerCase();

  const betweenTrieu = t.match(
      /từ\s*(\d+(?:[.,]\d+)?)\s*(?:triệu|tr)\s*(?:đến|tới|toi)\s*(\d+(?:[.,]\d+)?)\s*(?:triệu|tr)\b/i,
  );
  if (betweenTrieu) {
    min = parseNumberVi(betweenTrieu[1]) * 1e6;
    max = parseNumberVi(betweenTrieu[2]) * 1e6;
    explicit = true;
    return {min, max, explicit};
  }

  const underTrieu = t.match(
      /(?:dưới|tối đa|toi da|<=|max)\s*(\d+(?:[.,]\d+)?)\s*(?:triệu|tr)\b/i,
  );
  if (underTrieu) {
    max = Math.round(parseNumberVi(underTrieu[1]) * 1e6);
    min = 0;
    explicit = true;
    return {min, max, explicit};
  }

  const aboveTrieu = t.match(
      /(?:trên|tối thiểu|toi thieu|>=|min)\s*(\d+(?:[.,]\d+)?)\s*(?:triệu|tr)\b/i,
  );
  if (aboveTrieu) {
    min = Math.round(parseNumberVi(aboveTrieu[1]) * 1e6);
    max = DEFAULT_PRICE_MAX;
    explicit = true;
    return {min, max, explicit};
  }

  const rawTy = t.match(/(\d+(?:[.,]\d+)?)\s*(?:tỷ|ty)\b/i);
  if (rawTy) {
    const v = Math.round(parseNumberVi(rawTy[1]) * 1e9);
    max = v;
    explicit = true;
    return {min, max, explicit};
  }

  const rawTrieu = t.match(/\b(\d+(?:[.,]\d+)?)\s*(?:triệu|tr)\b/i);
  if (rawTrieu) {
    const v = Math.round(parseNumberVi(rawTrieu[1]) * 1e6);
    max = Math.max(v, min);
    min = 0;
    explicit = true;
    return {min, max, explicit};
  }

  const rawK = t.match(/\b(\d+(?:[.,]\d+)?)\s*(?:k|nghìn|nghin)\b/i);
  if (rawK) {
    const v = Math.round(parseNumberVi(rawK[1]) * 1e3);
    max = Math.min(Math.max(v, min), DEFAULT_PRICE_MAX);
    explicit = true;
    return {min, max, explicit};
  }

  return {min, max, explicit};
}

function isInStock(data) {
  const st = data.status || "";
  if (st === "Hết hàng") return false;
  const q = typeof data.quantity === "number" ? data.quantity : 0;
  if (q > 0) return true;
  if (Array.isArray(data.options) && data.options.length > 0) {
    const sum = data.options.reduce((acc, o) => {
      const oq = typeof o.quantity === "number" ? o.quantity : 0;
      return acc + oq;
    }, 0);
    return sum > 0;
  }
  return st === "Còn hàng";
}

function stripHtml(s) {
  return String(s || "").replace(/<[^>]+>/g, " ").replace(/\s+/g, " ").trim();
}

function compactProduct(doc) {
  const d = doc.data();
  const specs = Array.isArray(d.specifications) ?
    d.specifications.slice(0, 6).map((s) => `${s.label}: ${s.value}`).join("; ") :
    "";
  const desc = stripHtml(d.description || "").slice(0, 450);
  return {
    id: doc.id,
    name: d.name || "",
    price: typeof d.price === "number" ? d.price : 0,
    categoryId: d.categoryId || "",
    description: desc,
    specifications: specs,
  };
}

async function loadCandidates(budget) {
  const snap = await admin.firestore()
      .collection("products")
      .orderBy("createdAt", "desc")
      .limit(250)
      .get();

  let rows = snap.docs
      .map((doc) => ({doc, c: compactProduct(doc)}))
      .filter(({doc}) => isInStock(doc.data()));

  rows = rows.filter(({c}) => c.price >= budget.min && c.price <= budget.max);
  rows = rows.slice(0, MAX_CANDIDATES);
  return rows.map((r) => r.c);
}

function validateSuggestions(suggested, allowedIds) {
  const set = new Set(allowedIds);
  const out = [];
  for (const item of suggested || []) {
    const pid = item.productId;
    if (pid && set.has(pid)) {
      out.push({
        productId: pid,
        reason: String(item.reason || "").slice(0, 300),
      });
    }
  }
  return out.slice(0, 8);
}

/**
 * Ưu tiên: Firebase Secret → process.env PAYOS_* → key demo (local/emulator).
 * Trim để tránh newline khi set secret.
 */
function payosCredentialTriple() {
  const fromSecret = {
    clientId: String(payosClientId.value() || "").trim(),
    apiKey: String(payosApiKeySecret.value() || "").trim(),
    checksumKey: String(payosChecksumKey.value() || "").trim(),
  };
  const fromEnv = {
    clientId: String(process.env.PAYOS_CLIENT_ID || "").trim(),
    apiKey: String(process.env.PAYOS_API_KEY || "").trim(),
    checksumKey: String(process.env.PAYOS_CHECKSUM_KEY || "").trim(),
  };
  return {
    clientId: PAYOS_DEFAULT_CLIENT_ID,
    apiKey:  PAYOS_DEFAULT_API_KEY,
    checksumKey:PAYOS_DEFAULT_CHECKSUM_KEY,
  };
}

function makePayOS() {
  const c = payosCredentialTriple();
  return new PayOS({
    clientId: c.clientId,
    apiKey: c.apiKey,
    checksumKey: c.checksumKey,
  });
}

/**
 * Tạo payment link qua REST giống tích hập axios trong pharma_booking (cùng endpoint + chữ ký).
 */
async function createPayOsPaymentLinkRest(cred, payload) {
  const signatureData =
    `amount=${payload.amount}&cancelUrl=${payload.cancelUrl}&description=${payload.description}&orderCode=${payload.orderCode}&returnUrl=${payload.returnUrl}`;
  const signature = crypto.createHmac("sha256", cred.checksumKey).update(signatureData).digest("hex");
  const body = {...payload, signature};

  const res = await fetch(`${PAYOS_MERCHANT_API}/v2/payment-requests`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-client-id": cred.clientId,
      "x-api-key": cred.apiKey,
    },
    body: JSON.stringify(body),
  });

  const json = await res.json();
  if (json.code === "00" && json.data && json.data.checkoutUrl) {
    return {
      checkoutUrl: json.data.checkoutUrl,
      paymentLinkId: json.data.paymentLinkId || "",
    };
  }
  throw new APIError(
      200,
      {code: json.code, desc: json.desc},
      json.desc || "PayOS từ chối tạo link",
      res.headers,
  );
}

async function clearUserCart(userId) {
  const snap = await admin.firestore()
      .collection("carts")
      .doc(userId)
      .collection("items")
      .get();
  const batch = admin.firestore().batch();
  for (const doc of snap.docs) {
    batch.delete(doc.ref);
  }
  if (!snap.empty) {
    await batch.commit();
  }
}

function isPayOsSuccessCode(code) {
  const s = String(code ?? "").trim();
  return s === "00" || s === "0";
}

/**
 * returnUrl/cancelUrl từ client: chỉ HTTPS hosting hoặc figurestore://payment/...
 * @param {"return"|"cancel"} kind
 */
function validatePayOsCallbackUrl(urlStr, orderId, kind) {
  const webOrigin = PAYOS_APP_ORIGIN.replace(/\/$/, "");
  const expectedPath =
      kind === "return" ? "/payment/payos-return" : "/payment/payos-cancel";
  let u;
  try {
    u = new URL(urlStr);
  } catch {
    return false;
  }
  if (u.protocol === "https:") {
    if (u.origin !== webOrigin) return false;
    if (u.pathname !== expectedPath) return false;
    return u.searchParams.get("orderId") === orderId;
  }
  if (u.protocol === "figurestore:") {
    if (u.hostname !== "payment") return false;
    const p = u.pathname;
    if (kind === "return" && p !== "/success") return false;
    if (kind === "cancel" && p !== "/cancel") return false;
    return u.searchParams.get("orderId") === orderId;
  }
  return false;
}

exports.payosCreatePaymentLink = onRequest(
    {
      cors: false,
      secrets: [payosClientId, payosApiKeySecret, payosChecksumKey],
      timeoutSeconds: 60,
      memory: "256MiB",
    },
    async (req, res) => {
      applyCors(req, res);
      if (req.method === "OPTIONS") {
        res.status(204).send("");
        return;
      }
      if (req.method !== "POST") {
        res.status(405).json({error: "POST only"});
        return;
      }

      const authHeader = req.headers.authorization || "";
      const m = authHeader.match(/^Bearer (.+)$/i);
      if (!m) {
        res.status(401).json({error: "Thiếu Authorization Bearer token"});
        return;
      }

      let decoded;
      try {
        decoded = await admin.auth().verifyIdToken(m[1]);
      } catch (e) {
        res.status(401).json({error: "Token không hợp lệ"});
        return;
      }

      const orderId = req.body && req.body.orderId;
      if (!orderId || typeof orderId !== "string") {
        res.status(400).json({error: "orderId bắt buộc"});
        return;
      }

      try {
        const orderRef = admin.firestore().collection("orders").doc(orderId);
        const orderSnap = await orderRef.get();
        if (!orderSnap.exists) {
          res.status(404).json({error: "Không tìm thấy đơn hàng"});
          return;
        }
        const order = orderSnap.data();

        if (order.userId !== decoded.uid) {
          res.status(403).json({error: "Không có quyền"});
          return;
        }
        if (order.paymentMethod !== "payos") {
          res.status(400).json({error: "Đơn không dùng PayOS"});
          return;
        }
        const isAlreadyPaid = order.paymentStatus === "paid" || order.status === "paid";
        if (isAlreadyPaid) {
          res.status(400).json({error: "Đơn đã thanh toán"});
          return;
        }
        const payOsCode = order.payosOrderCode;
        if (typeof payOsCode !== "number") {
          res.status(400).json({error: "Thiếu payosOrderCode"});
          return;
        }

        if (order.payosCheckoutUrl && typeof order.payosCheckoutUrl === "string") {
          res.json({checkoutUrl: order.payosCheckoutUrl});
          return;
        }

        const items = Array.isArray(order.items) ? order.items.map((it) => ({
          name: String(it.productName || "Sản phẩm").slice(0, 255),
          quantity: Math.max(1, parseInt(it.quantity, 10) || 1),
          price: Math.max(0, parseInt(it.price, 10) || 0),
          unit: "sp",
        })) : [];

        const amount = Math.max(0, parseInt(order.total, 10) || 0);
        const description =
          `Thanh toán đơn ${order.orderCode || orderId}`.slice(0, 240);
        let returnUrl =
          `${PAYOS_APP_ORIGIN}/payment/payos-return?orderId=${encodeURIComponent(orderId)}`;
        let cancelUrl =
          `${PAYOS_APP_ORIGIN}/payment/payos-cancel?orderId=${encodeURIComponent(orderId)}`;

        const bodyReturn = req.body && req.body.returnUrl;
        const bodyCancel = req.body && req.body.cancelUrl;
        if (typeof bodyReturn === "string" && bodyReturn.trim() &&
            typeof bodyCancel === "string" && bodyCancel.trim()) {
          const r = bodyReturn.trim();
          const c = bodyCancel.trim();
          if (!validatePayOsCallbackUrl(r, orderId, "return") ||
              !validatePayOsCallbackUrl(c, orderId, "cancel")) {
            res.status(400).json({error: "returnUrl/cancelUrl không hợp lệ"});
            return;
          }
          returnUrl = r;
          cancelUrl = c;
        }

        const cred = payosCredentialTriple();
        if (!cred.clientId || !cred.apiKey || !cred.checksumKey) {
          res.status(500).json({
            error: "PayOS secrets rỗng — kiểm tra PAYOS_* đã gắn vào function và redeploy",
          });
          return;
        }

        const lineItems = items.length > 0 ? items : [{
          name: description.slice(0, 250),
          quantity: 1,
          price: amount,
          unit: "sp",
        }];

        const {checkoutUrl, paymentLinkId} = await createPayOsPaymentLinkRest(cred, {
          orderCode: payOsCode,
          amount,
          description,
          buyerName: String(order.fullName || ""),
          buyerPhone: String(order.phone || ""),
          buyerEmail: "",
          buyerAddress: String(order.address || "").slice(0, 500),
          items: lineItems,
          cancelUrl,
          returnUrl,
          expiredAt: Math.floor(Date.now() / 1000) + 30 * 60,
        });

        await orderRef.update({
          payosPaymentLinkId: paymentLinkId || "",
          payosCheckoutUrl: checkoutUrl,
          updatedAt: new Date().toISOString(),
        });

        res.json({checkoutUrl});
      } catch (err) {
        console.error("payosCreatePaymentLink", err);
        if (err instanceof APIError) {
          const body = {
            error: err.message || "PayOS từ chối tạo link",
            payosCode: err.code,
            payosDesc: err.desc,
          };
          if (String(err.code) === "214") {
            body.hint = "PayOS: kênh/cổng chưa hoạt động, đã tạm dừng, hoặc credential không khớp " +
              "kênh đang bật (kiểm tra dashboard + xác thực doanh nghiệp + liên kết ngân hàng). " +
              "Hotline PayOS: 1900 8144.";
          }
          res.status(502).json(body);
          return;
        }
        res.status(500).json({
          error: err.message || "Lỗi tạo link PayOS",
        });
      }
    },
);

exports.payosWebhook = onRequest(
    {
      cors: false,
      secrets: [payosClientId, payosApiKeySecret, payosChecksumKey],
      timeoutSeconds: 60,
      memory: "256MiB",
      invoker: "public",
    },
    async (req, res) => {
      if (req.method === "GET") {
        res.status(200).send("payos webhook ok");
        return;
      }
      if (req.method !== "POST") {
        res.status(405).send("Method Not Allowed");
        return;
      }

      try {
        const payOS = makePayOS();
        const webhookPayload = req.body;
        const data = await payOS.webhooks.verify(webhookPayload);

        if (!isPayOsSuccessCode(data.code)) {
          res.status(200).json({received: true, ignored: true});
          return;
        }

        const orderCode = data.orderCode;
        const qs = await admin.firestore()
            .collection("orders")
            .where("payosOrderCode", "==", orderCode)
            .limit(2)
            .get();

        if (qs.empty) {
          console.warn("payosWebhook: no order for orderCode", orderCode);
          res.status(200).json({received: true});
          return;
        }
        if (qs.size > 1) {
          console.warn("payosWebhook: multiple orders for orderCode", orderCode);
        }

        const doc = qs.docs[0];
        const ref = doc.ref;
        const o = doc.data();
        const reference = String(data.reference || "");

        if (o.paymentStatus === "paid" || o.status === "paid") {
          if (o.payosLastReference === reference) {
            res.status(200).json({received: true, duplicate: true});
            return;
          }
          res.status(200).json({received: true, alreadyPaid: true});
          return;
        }

        await admin.firestore().runTransaction(async (tx) => {
          const snap = await tx.get(ref);
          const cur = snap.data();
          if (cur.paymentStatus === "paid" || cur.status === "paid") {
            return;
          }
          tx.update(ref, {
            paymentStatus: "paid",
            payosLastReference: reference || null,
            updatedAt: new Date().toISOString(),
          });
        });

        const after = (await ref.get()).data();
        if (after && after.userId) {
          await clearUserCart(after.userId);
        }

        res.status(200).json({received: true, ok: true});
      } catch (err) {
        console.error("payosWebhook", err);
        res.status(400).json({error: "invalid webhook"});
      }
    },
);

exports.productChatbot = onRequest(
    {
      cors: false,
      secrets: [geminiApiKey],
      timeoutSeconds: 120,
      memory: "512MiB",
    },
    async (req, res) => {
      applyCors(req, res);

      if (req.method === "OPTIONS") {
        res.status(204).send("");
        return;
      }
      if (req.method !== "POST") {
        res.status(405).json({error: "POST only"});
        return;
      }

      try {
        const body = req.body || {};
        const rawMessages = Array.isArray(body.messages) ? body.messages : [];
        const messages = rawMessages
            .filter((m) => m && (m.role === "user" || m.role === "assistant"))
            .map((m) => ({
              role: m.role,
              content: String(m.content || "").slice(0, 8000),
            }))
            .slice(-MAX_HISTORY);

        if (messages.length === 0 ||
            messages[messages.length - 1].role !== "user") {
          res.status(400).json({error: "Cần ít nhất một tin nhắn user cuối cùng."});
          return;
        }

        const budget = inferBudgetFromMessages(messages);
        const candidates = await loadCandidates(budget);
        const allowedIds = candidates.map((c) => c.id);

        const apiKey = geminiApiKey.value();
        if (!apiKey) {
          res.status(500).json({error: "Thiếu cấu hình GEMINI_API_KEY (secret)."});
          return;
        }

        const genAI = new GoogleGenerativeAI(apiKey);
        const model = genAI.getGenerativeModel({
          model: "gemini-2.5-flash",
          generationConfig: {
            temperature: 0.35,
            maxOutputTokens: 2048,
            responseMimeType: "application/json",
            responseSchema: {
              type: "object",
              properties: {
                assistantMessage: {type: "string"},
                needsClarification: {type: "boolean"},
                suggestedProducts: {
                  type: "array",
                  items: {
                    type: "object",
                    properties: {
                      productId: {type: "string"},
                      reason: {type: "string"},
                    },
                    required: ["productId", "reason"],
                  },
                },
              },
              required: ["assistantMessage", "needsClarification", "suggestedProducts"],
            },
          },
        });

        const systemPreamble =
          `Bạn là nhân viên tư vấn tại Figure Store — cửa hàng chuyên figure và mô hình (anime, game, mecha, v.v.) ở Việt Nam. ` +
          `Dùng tiếng Việt, ngắn gọn, nhiệt tình; có thể nhắc khéo tỉ lệ (vd. 1/7, 1/8), phong cách, mức giá phù hợp người mới hay collector. ` +
          `Chỉ gợi ý sản phẩm có id trong CANDIDATES; không bịa id hoặc giá. ` +
          `Nếu chưa rõ (nhân vật/chủ đề/ ngân sách/ tỉ lệ), đặt needsClarification=true và hỏi một câu cụ thể; suggestedProducts có thể để rỗng. ` +
          `Nếu đủ thông tin, chọn tối đa 5 sản phẩm phù hợp và giải thích ngắn trong reason. ` +
          `Ngân sách ước lượng từ hội thoại (VND): min=${budget.min}, max=${budget.max}, ` +
          `explicit=${budget.explicit}.`;

        const catalogJson = JSON.stringify(candidates);
        const historyText = messages
            .map((m) => `${m.role === "user" ? "Khách" : "Bot"}: ${m.content}`)
            .join("\n");

        const prompt = `${systemPreamble}\n\n` +
          `CANDIDATES (JSON, chỉ được chọn productId trong mảng này):\n${catalogJson}\n\n` +
          `Hội thoại:\n${historyText}\n\n` +
          `Trả về đúng JSON theo schema đã cấu hình.`;

        const result = await model.generateContent(prompt);
        const text = result.response.text();
        let parsed;
        try {
          parsed = JSON.parse(text);
        } catch (e) {
          res.status(502).json({
            error: "Phản hồi model không phải JSON hợp lệ.",
            raw: text.slice(0, 500),
          });
          return;
        }

        const assistantMessage = String(parsed.assistantMessage || "").trim() ||
          "Xin lỗi, tôi chưa có figure hay mô hình nào phù hợp trong lần này.";
        const needsClarification = Boolean(parsed.needsClarification);
        const suggestedProducts = validateSuggestions(
            parsed.suggestedProducts,
            allowedIds,
        );

        res.json({
          assistantMessage,
          needsClarification,
          suggestedProducts,
          budgetResolved: {min: budget.min, max: budget.max, explicit: budget.explicit},
          candidateCount: candidates.length,
        });
      } catch (err) {
        console.error(err);
        res.status(500).json({
          error: err.message || "Lỗi server",
        });
      }
    },
);
