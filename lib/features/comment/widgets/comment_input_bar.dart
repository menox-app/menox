import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core/core/apis/app/interfaces/comment.dart';
import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/media/app_image.dart';
import 'package:flutter_core/core/ui/feedback/app_spinner.dart';
import 'package:flutter_core/features/auth/providers/auth_provider.dart';
import 'package:flutter_core/features/comment/providers/comment_providers.dart';
import 'package:flutter_core/features/user/providers/user_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class CommentInputBar extends ConsumerStatefulWidget {
  final Post post;
  final Comment? parentComment;

  const CommentInputBar({super.key, required this.post, this.parentComment});

  @override
  ConsumerState<CommentInputBar> createState() => _CommentInputBarState();
}

class _CommentInputBarState extends ConsumerState<CommentInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _picker = ImagePicker();

  XFile? _selectedMedia;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _canPost =>
      _controller.text.trim().isNotEmpty || _selectedMedia != null;

  Future<void> _pickMedia() async {
    HapticFeedback.selectionClick();
    final file = await _picker.pickMedia();
    if (file != null) {
      setState(() => _selectedMedia = file);
    }
  }

  Future<void> _submit() async {
    if (!_canPost || _isPosting) return;

    setState(() => _isPosting = true);
    try {
      final content = _controller.text.trim();
      final selectedMedia = _selectedMedia;
      final submitFuture = ref
          .read(commentActionProvider.notifier)
          .createCommentWithMedia(
            postId: widget.post.id,
            content: content,
            parentId: widget.parentComment?.id,
            file: selectedMedia == null ? null : File(selectedMedia.path),
          );

      _controller.clear();
      setState(() => _selectedMedia = null);
      _focusNode.unfocus();

      await submitFuture;
    } catch (error) {
      if (!mounted) return;

      if (!ref.read(authProvider).isAuthenticated) return;

      await _showCommentFailedDialog(_commentErrorMessage(error));
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Future<void> _showCommentFailedDialog(String message) {
    return showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Không thể gửi bình luận'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _commentErrorMessage(Object error) {
    if (error is DioException) {
      switch (error.response?.statusCode) {
        case 400:
          return 'Không thể tải ảnh lên hoặc nội dung chưa hợp lệ. Vui lòng kiểm tra lại và thử lần nữa.';
        case 413:
          return 'Tệp bạn chọn quá lớn. Vui lòng chọn tệp nhỏ hơn.';
        case 500:
        case 502:
        case 503:
        case 504:
          return 'Máy chủ đang gặp sự cố. Vui lòng thử lại sau.';
      }

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Kết nối mất quá lâu. Vui lòng thử lại.';
        case DioExceptionType.connectionError:
          return 'Không thể kết nối máy chủ. Vui lòng kiểm tra mạng.';
        case DioExceptionType.cancel:
          return 'Yêu cầu đã bị hủy. Vui lòng thử lại.';
        case DioExceptionType.badCertificate:
        case DioExceptionType.badResponse:
        case DioExceptionType.unknown:
          break;
      }
    }

    return 'Đã có lỗi xảy ra. Vui lòng thử lại.';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: ShadcnColors.background.withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(color: ShadcnColors.border, width: 0.5),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        12,
        AppSpacing.screenEdge,
        12 + (bottomInset > 0 ? 0 : MediaQuery.of(context).padding.bottom),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedMedia != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),

              child: Row(
                children: [
                  _MediaPreview(
                    file: _selectedMedia!,
                    onRemove: () => setState(() => _selectedMedia = null),
                  ),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppImage.avatar(
                url: user?.avatarUrl,
                size: 32,
                backgroundColor: ShadcnColors.secondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CupertinoTextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: 5,
                  minLines: 1,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: ShadcnColors.secondary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ShadcnColors.border, width: 0.5),
                  ),
                  placeholder:
                      'Reply to ${widget.post.author?.username ?? 'thread'}...',
                  placeholderStyle: const TextStyle(
                    color: ShadcnColors.mutedForeground,
                    fontSize: AppFontSizes.bodySmall,
                  ),
                  style: const TextStyle(
                    color: ShadcnColors.foreground,
                    fontSize: AppFontSizes.bodySmall,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (!_isPosting)
                CupertinoButton(
                  onPressed: _pickMedia,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size.square(32),
                  child: const Icon(
                    FluentIcons.image_sparkle_24_regular,
                    color: ShadcnColors.mutedForeground,
                    size: 22,
                  ),
                ),
              const SizedBox(width: 8),
              if (_isPosting)
                const AppSpinner(size: 20)
              else
                SizedBox(
                  height: 32,
                  child: CupertinoButton(
                    onPressed: _canPost ? _submit : null,
                    color: ShadcnColors.primary,
                    disabledColor: ShadcnColors.primary.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(999),
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: const Text(
                      'Post',
                      style: TextStyle(
                        color: ShadcnColors.primaryForeground,
                        fontSize: AppFontSizes.meta,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MediaPreview extends StatelessWidget {
  final XFile file;
  final VoidCallback onRemove;

  const _MediaPreview({required this.file, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 100,
            width: 100,
            child: Image.file(File(file.path), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: ShadcnColors.primary,
              shape: BoxShape.circle,
            ),
            child: CupertinoButton(
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              minimumSize: const Size.square(20),
              child: const Icon(
                FluentIcons.dismiss_16_regular,
                color: ShadcnColors.primaryForeground,
                size: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
