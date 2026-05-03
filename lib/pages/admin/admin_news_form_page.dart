import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import '../../models/news_model.dart';
import '../../services/news_service.dart';
import '../../services/image_service.dart';
import '../../services/auth_service.dart';
import '../../config/colors.dart';

class AdminNewsFormPage extends StatefulWidget {
  final String? newsId; // null = create, not null = edit

  const AdminNewsFormPage({
    super.key,
    this.newsId,
  });

  @override
  State<AdminNewsFormPage> createState() => _AdminNewsFormPageState();
}

class _AdminNewsFormPageState extends State<AdminNewsFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _newsService = NewsService();
  final _imageService = ImageService();
  final _authService = AuthService();
  
  final _titleController = TextEditingController();
  final _summaryController = TextEditingController();
  final _contentController = quill.QuillController.basic();
  final _authorController = TextEditingController();
  final _readTimeController = TextEditingController();
  final _categoryController = TextEditingController();
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  
  PlatformFile? _selectedImageFile;
  String? _imageUrl;
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isUploadingEditorImage = false;
  bool _isPublished = false;
  DateTime _publishDate = DateTime.now();
  NewsModel? _existingNews;

  final List<String> _categories = [
    'Sản phẩm mới',
    'Khuyến mãi',
    'Sự kiện',
    'Hướng dẫn',
    'Tin tức',
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    if (widget.newsId != null) {
      _loadNewsData();
    }
  }

  Future<void> _loadCurrentUser() async {
    final user = _authService.currentUser;
    if (user != null) {
      final userData = await _authService.getCurrentUserData();
      setState(() {
        _authorController.text = userData?.displayName ?? user.email ?? 'Admin';
      });
    }
  }

  Future<void> _loadNewsData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final news = await _newsService.getNewsById(widget.newsId!);
      if (news != null && mounted) {
        setState(() {
          _existingNews = news;
          _titleController.text = news.title;
          _summaryController.text = news.summary;
          // Load content for Quill editor
          try {
            final contentJson = jsonDecode(news.content);
            _contentController.document = quill.Document.fromJson(contentJson);
          } catch (e) {
            // If content is not in JSON format, set it as plain text
            _contentController.document = quill.Document()..insert(0, news.content);
          }
          _authorController.text = news.author;
          _readTimeController.text = news.readTime;
          _categoryController.text = news.category;
          _imageUrl = news.imageUrl;
          _isPublished = news.isPublished;
          _publishDate = news.publishDate;
        });
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không tìm thấy bài viết'),
            backgroundColor: Colors.red,
          ),
        );
        context.go('/admin/news');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải dữ liệu: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedImageFile = result.files.first;
          _imageUrl = null; // Clear existing URL when new file is selected
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chọn ảnh: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate content
    if (_contentController.document.toPlainText().trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung bài viết'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate image
    if (_imageUrl == null && _selectedImageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ảnh cho bài viết'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _isUploading = true;
    });

    try {
      String finalImageUrl = _imageUrl ?? '';

      // Upload new image if selected
      if (_selectedImageFile != null) {
        final uploadedUrl = await _imageService.uploadImage(
          platformFile: _selectedImageFile!,
          folder: 'news',
        );
        finalImageUrl = uploadedUrl;
      }

      // Get content from Quill editor as Delta JSON
      final contentJson = jsonEncode(_contentController.document.toDelta().toJson());
      
      final now = DateTime.now();
      final news = NewsModel(
        id: widget.newsId ?? '',
        title: _titleController.text.trim(),
        summary: _summaryController.text.trim(),
        content: contentJson,
        imageUrl: finalImageUrl,
        category: _categoryController.text.trim(),
        publishDate: _publishDate,
        author: _authorController.text.trim(),
        readTime: _readTimeController.text.trim(),
        isPublished: _isPublished,
        createdAt: _existingNews?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.newsId != null) {
        // Update existing news
        await _newsService.updateNews(widget.newsId!, news);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật bài viết thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Create new news
        await _newsService.createNews(news);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tạo bài viết thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      if (mounted) {
        context.go('/admin/news');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _selectPublishDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _publishDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _publishDate = picked;
      });
    }
  }

  Future<void> _insertImageFromDevice() async {
    try {
      // Pick image from device
      final imageFile = await _imageService.pickImage();
      if (imageFile == null) return;

      setState(() {
        _isUploadingEditorImage = true;
      });

      // Upload image to Firebase Storage
      final imageUrl = await _imageService.uploadImage(
        platformFile: imageFile,
        folder: 'news/content',
      );

      // Insert image into Quill editor
      final index = _contentController.selection.baseOffset;
      final length = _contentController.selection.extentOffset - index;
      
      // Create delta to insert image
      final delta = Delta()
        ..retain(index)
        ..delete(length)
        ..insert('\n')
        ..insert({'image': imageUrl})
        ..insert('\n');
      
      _contentController.document.compose(
        delta,
        quill.ChangeSource.local,
      );

      // Move cursor after the image
      _contentController.updateSelection(
        TextSelection.collapsed(offset: index + 2),
        quill.ChangeSource.local,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã chèn ảnh thành công'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi chèn ảnh: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingEditorImage = false;
        });
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildImagePreview() {
    if (_isUploading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_selectedImageFile != null) {
      // Show preview of selected image
      if (kIsWeb) {
        if (_selectedImageFile!.bytes != null) {
          return Image.memory(
            _selectedImageFile!.bytes!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
          );
        } else {
          return const Center(
            child: Icon(Icons.error, size: 48),
          );
        }
      } else {
        if (_selectedImageFile!.path != null) {
          return Image.file(
            File(_selectedImageFile!.path!),
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
          );
        } else {
          return const Center(
            child: Icon(Icons.error, size: 48),
          );
        }
      }
    } else if (_imageUrl != null) {
      // Show existing image from URL
      return CachedNetworkImage(
        imageUrl: _imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 200,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(),
        ),
        errorWidget: (context, url, error) => const Center(
          child: Icon(Icons.error, size: 48),
        ),
      );
    } else {
      // Show placeholder
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              'Chưa có ảnh',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    _authorController.dispose();
    _readTimeController.dispose();
    _categoryController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.of(context).isMobile;
    final isDesktop = ResponsiveBreakpoints.of(context).isDesktop;

    final isEdit = widget.newsId != null;
    return Scaffold(
      backgroundColor: AppColors.adminBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        surfaceTintColor: AppColors.surface,
        shape: const Border(
          bottom: BorderSide(color: AppColors.adminBorder, width: 1),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 20),
          tooltip: 'Quay lại',
          onPressed: () => context.go('/admin/news'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isEdit ? 'Chỉnh sửa bài viết' : 'Tạo bài viết mới',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Soạn nội dung, chèn ảnh và xuất bản bài viết.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        titleSpacing: 4,
      ),
      body: _isLoading && _existingNews == null
          ? const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: AppColors.primary500,
                ),
              ),
            )
          : isDesktop
              ? _buildDesktopLayout(isMobile)
              : _buildMobileLayout(isMobile),
    );
  }

  Widget _buildDesktopLayout(bool isMobile) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Column - Form Fields
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormFieldsSection(isMobile),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Right Column - Rich Text Editor
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: _buildContentEditorSection(isMobile, isDesktop: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(bool isMobile) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormFieldsSection(isMobile),
            const SizedBox(height: 24),
            _buildContentEditorSection(isMobile, isDesktop: false),
            const SizedBox(height: 24),
            _buildActionButtons(),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFieldsSection(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image Section
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ảnh bài viết',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildImagePreview(),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Chọn ảnh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    if (_imageUrl != null || _selectedImageFile != null)
                      const SizedBox(width: 8),
                    if (_imageUrl != null || _selectedImageFile != null)
                      Expanded(
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _imageUrl = null;
                              _selectedImageFile = null;
                            });
                          },
                          icon: const Icon(Icons.delete),
                          label: const Text('Xóa ảnh'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Title
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Tiêu đề *',
            border: OutlineInputBorder(),
            hintText: 'Nhập tiêu đề bài viết',
          ),
          maxLines: 2,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập tiêu đề';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Summary
        TextFormField(
          controller: _summaryController,
          decoration: const InputDecoration(
            labelText: 'Tóm tắt *',
            border: OutlineInputBorder(),
            hintText: 'Nhập tóm tắt bài viết',
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Vui lòng nhập tóm tắt';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        // Category and Author Row
        if (!isMobile)
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _categoryController.text.isEmpty
                      ? null
                      : _categoryController.text,
                  decoration: const InputDecoration(
                    labelText: 'Danh mục *',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _categoryController.text = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn danh mục';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _authorController,
                  decoration: const InputDecoration(
                    labelText: 'Tác giả *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập tác giả';
                    }
                    return null;
                  },
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              DropdownButtonFormField<String>(
                value: _categoryController.text.isEmpty
                    ? null
                    : _categoryController.text,
                decoration: const InputDecoration(
                  labelText: 'Danh mục *',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoryController.text = value ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng chọn danh mục';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Tác giả *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tác giả';
                  }
                  return null;
                },
              ),
            ],
          ),
        const SizedBox(height: 16),
        // Read Time and Publish Date Row
        if (!isMobile)
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _readTimeController,
                  decoration: const InputDecoration(
                    labelText: 'Thời gian đọc',
                    border: OutlineInputBorder(),
                    hintText: 'VD: 5 phút',
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: _selectPublishDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Ngày xuất bản',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(_formatDate(_publishDate)),
                  ),
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              TextFormField(
                controller: _readTimeController,
                decoration: const InputDecoration(
                  labelText: 'Thời gian đọc',
                  border: OutlineInputBorder(),
                  hintText: 'VD: 5 phút',
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectPublishDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày xuất bản',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(_formatDate(_publishDate)),
                ),
              ),
            ],
          ),
        const SizedBox(height: 16),
        // Published Status
        SwitchListTile(
          title: const Text('Xuất bản'),
          subtitle: Text(
            _isPublished
                ? 'Bài viết sẽ hiển thị công khai'
                : 'Bài viết ở chế độ bản nháp',
          ),
          value: _isPublished,
          onChanged: (value) {
            setState(() {
              _isPublished = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildContentEditorSection(bool isMobile, {required bool isDesktop}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nội dung *',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: isDesktop 
                  ? MediaQuery.of(context).size.height - 200
                  : (isMobile ? 300 : 400),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  quill.QuillSimpleToolbar(
                    controller: _contentController,
                    config: quill.QuillSimpleToolbarConfig(
                      embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                      showClipboardPaste: true,
                      customButtons: [
                        // Custom image button that picks from device
                        quill.QuillToolbarCustomButtonOptions(
                          icon: _isUploadingEditorImage
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                  ),
                                )
                              : const Icon(Icons.image),
                          tooltip: 'Chèn ảnh từ máy',
                          onPressed: _isUploadingEditorImage ? null : _insertImageFromDevice,
                        ),
                      ],
                      buttonOptions: quill.QuillSimpleToolbarButtonOptions(
                        base: quill.QuillToolbarBaseButtonOptions(
                          afterButtonPressed: () {
                            _editorFocusNode.requestFocus();
                          },
                        ),
                        linkStyle: quill.QuillToolbarLinkStyleButtonOptions(
                          validateLink: (link) => true,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: quill.QuillEditor.basic(
                      controller: _contentController,
                      focusNode: _editorFocusNode,
                      scrollController: _editorScrollController,
                      config: quill.QuillEditorConfig(
                        placeholder: 'Viết nội dung chi tiết bài viết...',
                        padding: const EdgeInsets.all(16),
                        embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isLoading
              ? null
              : () => context.go('/admin/news'),
          child: const Text('Hủy'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: 32, vertical: 12),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(widget.newsId != null
                  ? 'Cập nhật'
                  : 'Tạo mới'),
        ),
      ],
    );
  }
}

