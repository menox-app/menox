import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core/core/apis/app/providers.dart';
import 'package:flutter_core/core/apis/app/interfaces/comment.dart';
import 'package:flutter_core/core/apis/app/interfaces/post.dart';
import 'package:flutter_core/core/apis/app/interfaces/upload.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/widgets/app_button.dart';
import 'package:flutter_core/core/ui/widgets/app_icon_button.dart';
import 'package:flutter_core/core/ui/widgets/app_image.dart';
import 'package:flutter_core/core/ui/widgets/app_spinner.dart';
import 'package:flutter_core/features/home/providers/post_providers.dart';
import 'package:flutter_core/features/user/providers/user_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

Future<void> showCreateCommentSheet(BuildContext context, Post post, {Comment? parentComment}) {
  return Navigator.of(context, rootNavigator: true).push(
    CupertinoModalSheetRoute<void>(
      swipeDismissible: true,
      overlayColor: const Color(0x22000000),
      viewportBuilder: (context, preferredTopInset, child) {
        return SheetViewport(
          padding: EdgeInsets.only(top: preferredTopInset),
          child: child,
        );
      },
      builder: (context) => CreateCommentSheet(post: post, parentComment: parentComment),
    ),
  );
}

enum _AttachmentType { image, video }

class _ComposerAttachment {
  final XFile file;
  final _AttachmentType type;

  const _ComposerAttachment({required this.file, required this.type});
}

class CreateCommentSheet extends ConsumerStatefulWidget {
  final Post post;
  final Comment? parentComment;

  const CreateCommentSheet({super.key, required this.post, this.parentComment});

  @override
  ConsumerState<CreateCommentSheet> createState() => _CreateCommentSheetState();
}

class _CreateCommentSheetState extends ConsumerState<CreateCommentSheet> {
  final _contentController = TextEditingController();
  final _focusNode = FocusNode();
  final _picker = ImagePicker();

  final List<_ComposerAttachment> _attachments = [];
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_onDraftChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _contentController
      ..removeListener(_onDraftChanged)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onDraftChanged() => setState(() {});

  bool get _hasText => _contentController.text.trim().isNotEmpty;
  bool get _canPost => _hasText || _attachments.isNotEmpty;
  bool get _hasDraft => _hasText || _attachments.isNotEmpty;

  Future<void> _close() async {
    if (!_hasDraft) {
      Navigator.of(context, rootNavigator: true).pop();
      return;
    }

    final shouldDiscard = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Discard comment?'),
        content: const Text('Your current draft will not be saved.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep writing'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (shouldDiscard == true && mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<void> _pickMedia() async {
    HapticFeedback.selectionClick();
    final files = await _picker.pickMultipleMedia();
    if (!mounted || files.isEmpty) return;
    setState(() {
      _attachments.addAll(
        files.map(
          (file) =>
              _ComposerAttachment(file: file, type: _inferAttachmentType(file)),
        ),
      );
    });
  }

  _AttachmentType _inferAttachmentType(XFile file) {
    final mimeType = file.mimeType;
    final name = file.name.toLowerCase();
    if (mimeType?.startsWith('video/') == true ||
        name.endsWith('.mp4') ||
        name.endsWith('.mov') ||
        name.endsWith('.m4v') ||
        name.endsWith('.webm')) {
      return _AttachmentType.video;
    }
    return _AttachmentType.image;
  }

  Future<void> _submit() async {
    if (!_canPost || _isPosting) return;

    setState(() => _isPosting = true);
    try {
      final medias = await _uploadAttachments();
      await ref.read(commentActionProvider.notifier).createComment(
        CreateCommentBody(
          postId: widget.post.id,
          content: _contentController.text.trim(),
          parentId: widget.parentComment?.id,
          medias: medias,
        ),
      );

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
    } catch (error) {
      if (!mounted) return;
      await _showSubmitError(error);
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  Future<List<CreateCommentMediaBody>> _uploadAttachments() async {
    if (_attachments.isEmpty) return const [];

    final files = _attachments.map((attachment) {
      return File(attachment.file.path);
    }).toList();

    final appApi = ref.read(appApiProvider);
    final response = files.length == 1
        ? await appApi.upload.single(
            IUploadSingleRequest(file: files.first, folder: 'comments'),
          )
        : await appApi.upload.multiple(
            IUploadMultipleRequest(files: files, folder: 'comments'),
          );

    final uploads = response.data is List
        ? response.data as List
        : [response.data];

    return uploads.indexed.map((entry) {
      final (index, upload) = entry;
      final mediaId = upload.mediaId;
      if (mediaId == null || mediaId.isEmpty) {
        throw StateError('Upload response missing mediaId at index $index');
      }
      return CreateCommentMediaBody(mediaId: mediaId, order: index);
    }).toList();
  }

  Future<void> _showSubmitError(Object error) {
    return showCupertinoDialog<void>(
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: SheetKeyboardDismissible(
        dismissBehavior: const SheetKeyboardDismissBehavior.onDragDown(
          isContentScrollAware: true,
        ),
        child: Sheet(
          scrollConfiguration: const SheetScrollConfiguration(),
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          decoration: const MaterialSheetDecoration(
            size: SheetSize.stretch,
            color: ShadcnColors.background,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
          ),
          child: SheetContentScaffold(
            backgroundColor: ShadcnColors.background,
            bottomBarVisibility: const BottomBarVisibility.always(
              ignoreBottomInset: true,
            ),
            topBar: _ComposerTopBar(onCancel: _close),
            body: _ComposerBody(
              post: widget.post,
              parentComment: widget.parentComment,
              contentController: _contentController,
              focusNode: _focusNode,
              attachments: _attachments,
              onRemoveAttachment: (index) =>
                  setState(() => _attachments.removeAt(index)),
              onPickMedia: _pickMedia,
            ),
            bottomBar: _ComposerBottomBar(
              canPost: _canPost,
              isPosting: _isPosting,
              onSubmit: _submit,
            ),
          ),
        ),
      ),
    );
  }
}

class _ComposerTopBar extends StatelessWidget {
  final VoidCallback onCancel;

  const _ComposerTopBar({required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: ShadcnColors.background,
        border: Border(
          bottom: BorderSide(color: ShadcnColors.border, width: 0.5),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'Reply',
            style: TextStyle(
              color: ShadcnColors.foreground,
              fontSize: AppFontSizes.input,
              fontWeight: FontWeight.w800,
            ),
          ),
          Positioned(
            right: 8,
            child: CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              onPressed: onCancel,
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: ShadcnColors.foreground,
                  fontSize: AppFontSizes.body,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComposerBody extends HookConsumerWidget {
  final Post post;
  final Comment? parentComment;
  final TextEditingController contentController;
  final FocusNode focusNode;
  final List<_ComposerAttachment> attachments;
  final ValueChanged<int> onRemoveAttachment;
  final VoidCallback onPickMedia;

  const _ComposerBody({
    required this.post,
    this.parentComment,
    required this.contentController,
    required this.focusNode,
    required this.attachments,
    required this.onRemoveAttachment,
    required this.onPickMedia,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final username = user?.username.isNotEmpty == true
        ? user!.username
        : 'memox_user';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Original Post / Parent Comment Context
          _OriginalPostContext(post: post, comment: parentComment),
          
          const SizedBox(height: 12),
          
          // Reply Row
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: ShadcnColors.border,
                          width: 0.5,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: AppImage.avatar(
                        url: user?.avatarUrl,
                        size: 46,
                        backgroundColor: ShadcnColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        username,
                        style: const TextStyle(
                          color: ShadcnColors.foreground,
                          fontSize: AppFontSizes.body,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextField(
                        controller: contentController,
                        focusNode: focusNode,
                        autofocus: true,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 1,
                        maxLines: null,
                        cursorColor: ShadcnColors.foreground,
                        style: const TextStyle(
                          color: ShadcnColors.foreground,
                          fontSize: AppFontSizes.body,
                          height: 1.35,
                        ),
                        decoration: InputDecoration(
                          hintText: "Reply to ${parentComment?.author?.username ?? post.author?.username}...",
                          hintStyle: const TextStyle(
                            color: ShadcnColors.mutedForeground,
                            fontSize: AppFontSizes.body,
                          ),
                          border: InputBorder.none,
                          isCollapsed: true,
                          contentPadding: const EdgeInsets.only(top: 6, bottom: 10),
                        ),
                      ),
                      if (attachments.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _AttachmentStrip(
                          attachments: attachments,
                          onRemoveAttachment: onRemoveAttachment,
                        ),
                      ],
                      const SizedBox(height: 8),
                      _ComposerToolbar(onPickMedia: onPickMedia),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OriginalPostContext extends StatelessWidget {
  final Post post;
  final Comment? comment;

  const _OriginalPostContext({required this.post, this.comment});

  @override
  Widget build(BuildContext context) {
    final author = comment?.author ?? post.author;
    final content = comment?.content ?? post.content;

    return Opacity(
      opacity: 0.6,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                AppImage.avatar(
                  url: author?.avatarUrl,
                  size: 32,
                  backgroundColor: ShadcnColors.secondary,
                ),
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    color: ShadcnColors.border,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    author?.username ?? 'user',
                    style: const TextStyle(
                      color: ShadcnColors.foreground,
                      fontSize: AppFontSizes.bodySmall,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    content ?? '',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ShadcnColors.foreground,
                      fontSize: AppFontSizes.bodySmall,
                      height: 1.3,
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
}

class _ComposerToolbar extends StatelessWidget {
  final VoidCallback onPickMedia;

  const _ComposerToolbar({required this.onPickMedia});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      runSpacing: 8,
      children: [
        _ComposerToolButton(
          icon: FluentIcons.image_sparkle_16_regular,
          onPressed: onPickMedia,
        ),
      ],
    );
  }
}

class _ComposerToolButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ComposerToolButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      icon: icon,
      onPressed: onPressed,
      size: AppButtonSize.sm,
      child: Icon(icon, color: ShadcnColors.mutedForeground, size: 22),
    );
  }
}

class _AttachmentStrip extends StatelessWidget {
  final List<_ComposerAttachment> attachments;
  final ValueChanged<int> onRemoveAttachment;

  const _AttachmentStrip({
    required this.attachments,
    required this.onRemoveAttachment,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: attachments.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return _AttachmentPreview(
            attachment: attachments[index],
            onRemove: () => onRemoveAttachment(index),
          );
        },
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  final _ComposerAttachment attachment;
  final VoidCallback onRemove;

  const _AttachmentPreview({required this.attachment, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 100,
            height: 100,
            color: ShadcnColors.secondary,
            child: switch (attachment.type) {
              _AttachmentType.video => _VideoAttachment(
                fileName: attachment.file.name,
              ),
              _ => _ImageAttachment(file: attachment.file),
            },
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: CupertinoColors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FluentIcons.dismiss_24_regular,
                color: CupertinoColors.white,
                size: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageAttachment extends StatelessWidget {
  final XFile file;

  const _ImageAttachment({required this.file});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: file.readAsBytes(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: AppSpinner(size: 18));
        }
        return Image.memory(snapshot.data!, fit: BoxFit.cover);
      },
    );
  }
}

class _VideoAttachment extends StatelessWidget {
  final String fileName;

  const _VideoAttachment({required this.fileName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            FluentIcons.play_24_filled,
            color: ShadcnColors.primary,
            size: 18,
          ),
          const SizedBox(height: 6),
          Text(
            fileName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ShadcnColors.mutedForeground,
              fontSize: AppFontSizes.caption,
            ),
          ),
        ],
      ),
    );
  }
}

class _ComposerBottomBar extends StatelessWidget {
  final bool canPost;
  final bool isPosting;
  final VoidCallback onSubmit;

  const _ComposerBottomBar({
    required this.canPost,
    required this.isPosting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: ShadcnColors.background,
        border: Border(
          top: BorderSide(color: ShadcnColors.border, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Anyone can reply',
            style: TextStyle(
              color: ShadcnColors.mutedForeground,
              fontSize: AppFontSizes.bodySmall,
            ),
          ),
          AppButton(
            text: 'Post',
            onPressed: onSubmit,
            size: AppButtonSize.sm,
            isLoading: isPosting,
            disabled: !canPost,
          ),
        ],
      ),
    );
  }
}
