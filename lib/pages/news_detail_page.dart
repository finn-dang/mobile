import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../models/news_model.dart';
import '../widgets/web_safe_network_image.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import '../services/news_service.dart';
import '../config/colors.dart';

class NewsDetailPage extends StatefulWidget {
  final String newsId;

  const NewsDetailPage({
    super.key,
    required this.newsId,
  });

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  final NewsService _newsService = NewsService();
  NewsModel? _article;
  bool _isLoading = true;
  final quill.QuillController _contentController = quill.QuillController.basic();

  @override
  void initState() {
    super.initState();
    _contentController.readOnly = true;
    _loadArticle();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadArticle() async {
    try {
      final article = await _newsService.getNewsById(widget.newsId);
      if (article != null && mounted) {
        setState(() {
          _article = article;
          // Load content for Quill editor (read-only)
          try {
            final contentJson = jsonDecode(article.content);
            _contentController.document = quill.Document.fromJson(contentJson);
          } catch (e) {
            // If content is not in JSON format, set it as plain text
            _contentController.document = quill.Document()..insert(0, article.content);
          }
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không tìm thấy bài viết'),
              backgroundColor: Colors.red,
            ),
          );
          context.go('/news');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải bài viết: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_article == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Tin tức'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'Không tìm thấy bài viết',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/news'),
                child: const Text('Quay lại danh sách'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            Container(
              width: double.infinity,
              height: isMobile ? 250 : 400,
              child: WebSafeNetworkImage(
                imageUrl: _article!.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.image_not_supported,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ),
            // Content
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : (isMobile ? 24 : 250),
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _article!.category,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    _article!.title,
                    style: TextStyle(
                      fontSize: isMobile ? 24 : 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Meta info
                  Row(
                    children: [
                      Icon(Icons.person_outline,
                          size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        _article!.author,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Icon(Icons.calendar_today,
                          size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(_article!.publishDate),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (_article!.readTime.isNotEmpty) ...[
                        const SizedBox(width: 24),
                        Icon(Icons.access_time,
                            size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          _article!.readTime,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Summary
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      _article!.summary,
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 18,
                        color: Colors.grey[700],
                        height: 1.6,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Content - Rich Text
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: quill.QuillEditor.basic(
                      controller: _contentController,
                      config: quill.QuillEditorConfig(
                        padding: EdgeInsets.zero,
                        embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Back button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/news'),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Quay lại danh sách'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

