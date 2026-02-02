import 'dart:io';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../api/api.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/r2_storage_service.dart';
import '../../home/data/post_provider.dart';

/// 게시물 작성/수정 화면
class PostCreateScreen extends ConsumerStatefulWidget {
  final String? postId; // null이면 새 작성, 있으면 수정

  const PostCreateScreen({super.key, this.postId});

  @override
  ConsumerState<PostCreateScreen> createState() => _PostCreateScreenState();
}

class _PostCreateScreenState extends ConsumerState<PostCreateScreen> {
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<String> _tags = [];
  List<String> _existingImages = []; // 기존 이미지 URL
  List<XFile> _newImages = []; // 새로 추가한 이미지
  bool _isLoading = false;
  bool _isInitialized = false;
  String _loadingMessage = '';

  bool get isEditing => widget.postId != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _loadPost();
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _loadPost() async {
    try {
      final post = await postsApi.getById(widget.postId!);
      setState(() {
        _contentController.text = post.content;
        _tags = List.from(post.tags);
        _existingImages = List.from(post.images);
        _isInitialized = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('게시물을 불러올 수 없습니다: $e'),
            behavior: SnackBarBehavior.fixed,
          ),
        );
        context.pop();
      }
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (images.isNotEmpty) {
      setState(() {
        _newImages.addAll(images);
      });
    }
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImages.removeAt(index);
    });
  }

  void _removeNewImage(int index) {
    setState(() {
      _newImages.removeAt(index);
    });
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<List<String>> _uploadImages() async {
    final supabase = ref.read(supabaseProvider);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('로그인이 필요합니다');

    if (_newImages.isEmpty) return [];

    final uploadedUrls = <String>[];

    for (var i = 0; i < _newImages.length; i++) {
      if (mounted) {
        setState(() {
          _loadingMessage = '이미지 업로드 중... (${i + 1}/${_newImages.length})';
        });
      }

      final image = _newImages[i];
      final bytes = await image.readAsBytes();
      final fileName =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      final extension = image.name.split('.').last.toLowerCase();

      // R2에 업로드
      final url = await r2Storage.uploadFile(
        bytes: bytes,
        fileName: fileName,
        contentType: 'image/$extension',
        folder: 'posts',
      );

      uploadedUrls.add(url);
    }

    return uploadedUrls;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('내용을 입력해주세요'),
          behavior: SnackBarBehavior.fixed,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _loadingMessage = '이미지 업로드 중...';
    });

    List<String> uploadedImageUrls = [];
    bool postSaved = false;

    try {
      // 새 이미지 업로드
      uploadedImageUrls = await _uploadImages();
      final allImages = [..._existingImages, ...uploadedImageUrls];

      if (mounted) {
        setState(() => _loadingMessage = '게시물 저장 중...');
      }

      if (isEditing) {
        // 수정
        await postsApi.update(
          widget.postId!,
          UpdatePostDto(content: content, images: allImages, tags: _tags),
        );
        postSaved = true;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('게시물이 수정되었습니다'),
              behavior: SnackBarBehavior.fixed,
              duration: Duration(seconds: 1),
            ),
          );
          context.pop(true);
        }
      } else {
        // 새 작성
        await postsApi.create(
          CreatePostDto(content: content, images: allImages, tags: _tags),
        );
        postSaved = true;

        if (mounted) {
          // 피드 새로고침
          ref.invalidate(postsProvider);
          ref.invalidate(popularPostsProvider);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('게시물이 작성되었습니다'),
              behavior: SnackBarBehavior.fixed,
              duration: Duration(seconds: 1),
            ),
          );
          context.pop(true);
        }
      }
    } catch (e) {
      // 게시물 저장 실패 시 업로드된 이미지 삭제
      if (!postSaved && uploadedImageUrls.isNotEmpty) {
        if (mounted) {
          setState(() => _loadingMessage = '업로드된 이미지 정리 중...');
        }

        // 모든 업로드된 이미지 삭제 시도
        for (final imageUrl in uploadedImageUrls) {
          try {
            await r2Storage.deleteFile(imageUrl);
          } catch (deleteError) {
            // 삭제 실패는 로그만 남기고 계속 진행
            if (kDebugMode) {
              print('❌ 이미지 삭제 실패: $imageUrl - $deleteError');
            }
          }
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류가 발생했습니다: $e'),
            behavior: SnackBarBehavior.fixed,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 수정 모드에서 로딩 중
    if (isEditing && !_isInitialized) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(LucideIcons.x),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => context.pop(),
        ),
        title: Text(
          isEditing ? '게시물 수정' : '새 게시물',
          style: GoogleFonts.notoSansKr(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: _isLoading
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _loadingMessage,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  )
                : TextButton(
                    onPressed: _submit,
                    child: Text(
                      isEditing ? '수정' : '게시',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 내용
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: '무슨 생각을 하고 계신가요?',
                  hintStyle: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: AppTypography.bodyMedium.copyWith(height: 1.6),
                maxLines: null,
                minLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '내용을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // 이미지
              _buildImageSection(),
              const SizedBox(height: AppSpacing.lg),

              // 태그
              _buildTagSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    final totalImages = _existingImages.length + _newImages.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.image, size: 18, color: AppColors.gray500),
            const SizedBox(width: 8),
            Text(
              '이미지',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '$totalImages/10',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // 이미지 그리드
        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // 추가 버튼
              if (totalImages < 10)
                GestureDetector(
                  onTap: _pickImages,
                  child: Container(
                    width: 100,
                    height: 100,
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.gray50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.gray200,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.plus,
                          size: 24,
                          color: AppColors.gray500,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '추가',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 기존 이미지
              ..._existingImages.asMap().entries.map((entry) {
                return _ImageThumbnail(
                  imageUrl: entry.value,
                  onRemove: () => _removeExistingImage(entry.key),
                );
              }),

              // 새 이미지
              ..._newImages.asMap().entries.map((entry) {
                return _ImageThumbnail(
                  file: entry.value,
                  onRemove: () => _removeNewImage(entry.key),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTagSection() {
    // 고정 해시태그 목록
    final availableTags = ['일상', '카페탐방', '질문', '장비추천', '브루잉', '에스프레소'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(LucideIcons.hash, size: 18, color: AppColors.gray500),
            const SizedBox(width: 8),
            Text(
              '태그 선택',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),

        // 고정 태그 선택
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableTags.map((tag) {
            final isSelected = _tags.contains(tag);
            return FilterChip(
              label: Text('#$tag'),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    if (!_tags.contains(tag)) {
                      _tags.add(tag);
                    }
                  } else {
                    _tags.remove(tag);
                  }
                });
              },
              backgroundColor: Colors.white,
              selectedColor: AppColors.primary.withValues(alpha: 0.15),
              checkmarkColor: AppColors.primary,
              labelStyle: AppTypography.labelMedium.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.gray300,
                width: isSelected ? 1.5 : 1,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ImageThumbnail extends StatelessWidget {
  final String? imageUrl;
  final XFile? file;
  final VoidCallback onRemove;

  const _ImageThumbnail({this.imageUrl, this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageUrl != null
                ? Image.network(
                    imageUrl!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.gray100,
                      child: const Icon(LucideIcons.image),
                    ),
                  )
                : Image.file(
                    File(file!.path),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.x, size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
