import 'dart:async';
import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core/core/apis/app/interfaces/comment.dart';
import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter_core/core/apis/app/interfaces/upload.dart';
import 'package:flutter_core/core/apis/app/providers.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/widgets/app_button.dart';
import 'package:flutter_core/core/ui/widgets/app_image.dart';
import 'package:flutter_core/core/ui/widgets/app_spinner.dart';
import 'package:flutter_core/features/home/providers/post_providers.dart';
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

  bool get _canPost => _controller.text.trim().isNotEmpty || _selectedMedia != null;

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
      List<CreateCommentMediaBody>? medias;
      
      if (_selectedMedia != null) {
        final file = File(_selectedMedia!.path);
        final appApi = ref.read(appApiProvider);
        final response = await appApi.upload.single(
          IUploadSingleRequest(file: file, folder: 'comments'),
        );
        final upload = response.data;
        if (upload.mediaId != null) {
          medias = [CreateCommentMediaBody(mediaId: upload.mediaId!, order: 0)];
        }
      }

      await ref.read(commentActionProvider.notifier).createComment(
        CreateCommentBody(
          postId: widget.post.id,
          content: _controller.text.trim(),
          parentId: widget.parentComment?.id,
          medias: medias,
        ),
      );

      _controller.clear();
      setState(() => _selectedMedia = null);
      _focusNode.unfocus();
    } catch (error) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Comment failed'),
            content: Text(error.toString()),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
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
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + (bottomInset > 0 ? 0 : MediaQuery.of(context).padding.bottom)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_selectedMedia != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _MediaPreview(
                file: _selectedMedia!,
                onRemove: () => setState(() => _selectedMedia = null),
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
                child: Container(
                  constraints: const BoxConstraints(minHeight: 40),
                  decoration: BoxDecoration(
                    color: ShadcnColors.secondary.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ShadcnColors.border, width: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: 5,
                    minLines: 1,
                    style: const TextStyle(
                      color: ShadcnColors.foreground,
                      fontSize: AppFontSizes.bodySmall,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Reply to ${widget.post.author?.username ?? 'thread'}...',
                      hintStyle: const TextStyle(
                        color: ShadcnColors.mutedForeground,
                        fontSize: AppFontSizes.bodySmall,
                      ),
                      border: InputBorder.none,
                      isCollapsed: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (!_isPosting)
                IconButton(
                  onPressed: _pickMedia,
                  icon: const Icon(
                    FluentIcons.image_sparkle_24_regular,
                    color: ShadcnColors.mutedForeground,
                    size: 22,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              const SizedBox(width: 8),
              if (_isPosting)
                const AppSpinner(size: 20)
              else
                AppButton(
                  text: 'Post',
                  onPressed: _submit,
                  size: AppButtonSize.xs,
                  disabled: !_canPost,
                  variant: AppButtonVariant.primary,
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
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 120,
            width: 120,
            child: Image.file(File(file.path), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FluentIcons.dismiss_16_regular,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
