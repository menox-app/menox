import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core/core/apis/app/providers.dart';
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

Future<void> showCreatePostSheet(BuildContext context) {
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
      builder: (context) => const CreatePostSheet(),
    ),
  );
}

enum _AttachmentType { image, video }

enum _ReplyPermission {
  anyone,
  followers,
  mentioned;

  String get label {
    switch (this) {
      case _ReplyPermission.anyone:
        return 'Anyone can reply';
      case _ReplyPermission.followers:
        return 'Followers only';
      case _ReplyPermission.mentioned:
        return 'Mentioned only';
    }
  }

  String get shortLabel {
    switch (this) {
      case _ReplyPermission.anyone:
        return 'Anyone can reply';
      case _ReplyPermission.followers:
        return 'Followers can reply';
      case _ReplyPermission.mentioned:
        return 'Mentioned can reply';
    }
  }

  String get ephemeralDescription {
    switch (this) {
      case _ReplyPermission.anyone:
        return 'Anyone can reply, others must request';
      case _ReplyPermission.followers:
        return 'Only your followers can reply, others must request';
      case _ReplyPermission.mentioned:
        return 'Only mentioned people can reply';
    }
  }
}

class _ComposerAttachment {
  final XFile file;
  final _AttachmentType type;

  const _ComposerAttachment({required this.file, required this.type});
}

class CreatePostSheet extends ConsumerStatefulWidget {
  const CreatePostSheet({super.key});

  @override
  ConsumerState<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends ConsumerState<CreatePostSheet> {
  final _contentController = TextEditingController();
  final _focusNode = FocusNode();
  final _picker = ImagePicker();

  final List<_ComposerAttachment> _attachments = [];
  bool _isPosting = false;
  _ReplyPermission _replyPermission = _ReplyPermission.anyone;
  bool _isEphemeral = false;

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
        title: const Text('Discard thread?'),
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
      final response = await ref
          .read(appApiProvider)
          .posts
          .createPost(
            CreatePostBody(
              content: _contentController.text.trim(),
              visibility: 'public',
              medias: medias,
            ),
          );

      if (!mounted) return;
      _prependPostToFeed(response.data);
      Navigator.of(context, rootNavigator: true).pop();
    } catch (error) {
      if (!mounted) return;
      await _showSubmitError(error);
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  void _prependPostToFeed(Post post) {
    ref.read(feedPostsProvider.notifier).prependPost(post);
    unawaited(ref.read(feedPostsProvider.notifier).refresh());
  }

  Future<List<CreatePostMediaBody>> _uploadAttachments() async {
    if (_attachments.isEmpty) return const [];

    final files = _attachments.map((attachment) {
      return File(attachment.file.path);
    }).toList();

    final appApi = ref.read(appApiProvider);
    final response = files.length == 1
        ? await appApi.upload.single(
            IUploadSingleRequest(file: files.first, folder: 'posts'),
          )
        : await appApi.upload.multiple(
            IUploadMultipleRequest(files: files, folder: 'posts'),
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
      return CreatePostMediaBody(mediaId: mediaId, order: index);
    }).toList();
  }

  Future<void> _showSubmitError(Object error) {
    return showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Post failed'),
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

  Future<void> _showPostSettings() async {
    HapticFeedback.selectionClick();
    final result = await showModalBottomSheet<_ReplyPermission>(
      context: context,
      backgroundColor: ShadcnColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) =>
          _PostSettingsSheet(initialPermission: _replyPermission),
    );

    if (result != null && mounted) {
      setState(() => _replyPermission = result);
    }
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
            topBar: _ComposerTopBar(
              onCancel: _close,
              isEphemeral: _isEphemeral,
            ),
            body: _ComposerBody(
              contentController: _contentController,
              focusNode: _focusNode,
              attachments: _attachments,
              onRemoveAttachment: (index) =>
                  setState(() => _attachments.removeAt(index)),
              onPickMedia: _pickMedia,
              isEphemeral: _isEphemeral,
            ),
            bottomBar: _ComposerBottomBar(
              canPost: _canPost,
              isPosting: _isPosting,
              onSubmit: _submit,
              replyPermission: _replyPermission,
              isEphemeral: _isEphemeral,
              onToggleEphemeral: () =>
                  setState(() => _isEphemeral = !_isEphemeral),
              onOpenSettings: () => _showPostSettings(),
            ),
          ),
        ),
      ),
    );
  }
}

class _ComposerTopBar extends StatelessWidget {
  final VoidCallback onCancel;
  final bool isEphemeral;

  const _ComposerTopBar({required this.onCancel, this.isEphemeral = false});

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
          Text(
            isEphemeral ? 'New ephemeral post' : 'New post',
            style: const TextStyle(
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
  final TextEditingController contentController;
  final FocusNode focusNode;
  final List<_ComposerAttachment> attachments;
  final ValueChanged<int> onRemoveAttachment;
  final VoidCallback onPickMedia;
  final bool isEphemeral;

  const _ComposerBody({
    required this.contentController,
    required this.focusNode,
    required this.attachments,
    required this.onRemoveAttachment,
    required this.onPickMedia,
    this.isEphemeral = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final username = user?.username.isNotEmpty == true
        ? user!.username
        : 'memox_user';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenEdge,
        22,
        AppSpacing.screenEdge,
        28,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Row 1: Avatar + thread line │ Name + topic + text input ──
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column: avatar → vertical thread line
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
                    // Vertical thread line (hidden in ephemeral mode)
                    if (!isEphemeral)
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
                // Right column: username + topic, text field, attachments, toolbar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Username row (topic hidden in ephemeral mode)
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              username,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: ShadcnColors.foreground,
                                fontSize: AppFontSizes.body,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (!isEphemeral) ...[
                            const SizedBox(width: 8),
                            const Icon(
                              FluentIcons.chevron_right_24_regular,
                              color: ShadcnColors.mutedForeground,
                              size: 12,
                            ),
                            const SizedBox(width: 6),
                            const Flexible(
                              child: Text(
                                'Add topic',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: ShadcnColors.mutedForeground,
                                  fontSize: AppFontSizes.bodySmall,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      // Text input
                      if (isEphemeral)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IntrinsicWidth(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(minWidth: 120),
                              child: CustomPaint(
                                painter: _DashedBubblePainter(
                                  color: ShadcnColors.border,
                                  strokeWidth: 1.5,
                                  dashWidth: 5,
                                  dashGap: 4,
                                  radius: 16,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    14,
                                    10,
                                    14,
                                    10,
                                  ),
                                  child: TextField(
                                    controller: contentController,
                                    focusNode: focusNode,
                                    autofocus: true,
                                    keyboardType: TextInputType.multiline,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    minLines: 1,
                                    maxLines: null,
                                    cursorColor: ShadcnColors.foreground,
                                    style: const TextStyle(
                                      color: ShadcnColors.foreground,
                                      fontSize: AppFontSizes.body,
                                      height: 1.35,
                                    ),
                                    decoration: const InputDecoration(
                                      hintText: "What's new?",
                                      hintStyle: TextStyle(
                                        color: ShadcnColors.mutedForeground,
                                        fontSize: AppFontSizes.body,
                                      ),
                                      border: InputBorder.none,
                                      isCollapsed: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      else
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
                          decoration: const InputDecoration(
                            hintText: "What's new?",
                            hintStyle: TextStyle(
                              color: ShadcnColors.mutedForeground,
                              fontSize: AppFontSizes.body,
                            ),
                            border: InputBorder.none,
                            isCollapsed: true,
                            contentPadding: EdgeInsets.only(top: 6, bottom: 10),
                          ),
                        ),
                      // Attachments (if any)
                      if (attachments.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _AttachmentStrip(
                          attachments: attachments,
                          onRemoveAttachment: onRemoveAttachment,
                        ),
                      ],
                      // ── Toolbar (hidden in ephemeral mode) ──
                      if (!isEphemeral) ...[
                        const SizedBox(height: 8),
                        _ComposerToolbar(onPickMedia: onPickMedia),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── "Add to thread" button (hidden in ephemeral mode) ──
          if (!isEphemeral) ...[
            const SizedBox(height: 4),
            Opacity(
              opacity: 0.35,
              child: Row(
                children: [
                  SizedBox(
                    width: 46,
                    child: Center(
                      child: AppImage.avatar(
                        url: user?.avatarUrl,
                        size: 22,
                        backgroundColor: ShadcnColors.secondary,
                        errorIconSize: 12,
                      ),
                    ),
                  ),
                  const Text(
                    'Add to thread',
                    style: TextStyle(
                      color: Color(0xFFD4D4D8),
                      fontSize: AppFontSizes.bodySmall,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // ── Ephemeral info notice ──
          if (isEphemeral) ...[const SizedBox(height: 24), _EphemeralNotice()],
        ],
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
      height: 128,
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
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 126,
            height: 126,
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
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: CupertinoColors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FluentIcons.dismiss_24_regular,
                color: CupertinoColors.white,
                size: 14,
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
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: ShadcnColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              FluentIcons.play_24_filled,
              color: ShadcnColors.primaryForeground,
              size: 20,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            fileName,
            maxLines: 2,
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
  final _ReplyPermission replyPermission;
  final bool isEphemeral;
  final VoidCallback onToggleEphemeral;
  final VoidCallback onOpenSettings;

  const _ComposerBottomBar({
    required this.canPost,
    required this.isPosting,
    required this.onSubmit,
    required this.replyPermission,
    required this.isEphemeral,
    required this.onToggleEphemeral,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ShadcnColors.background,
      padding: EdgeInsets.fromLTRB(
        20,
        10,
        20,
        MediaQuery.viewPaddingOf(context).bottom + 12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Reply permission label (tappable)
          Expanded(
            child: GestureDetector(
              onTap: onOpenSettings,
              behavior: HitTestBehavior.opaque,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    isEphemeral
                        ? FluentIcons.mail_24_regular
                        : FluentIcons.earth_24_regular,
                    color: ShadcnColors.mutedForeground,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      isEphemeral
                          ? replyPermission.ephemeralDescription
                          : replyPermission.shortLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ShadcnColors.mutedForeground,
                        fontSize: AppFontSizes.caption,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Ephemeral toggle
          GestureDetector(
            onTap: onToggleEphemeral,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 66,
              height: 40,
              decoration: BoxDecoration(
                color: ShadcnColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: isEphemeral
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isEphemeral
                        ? ShadcnColors.primary
                        : ShadcnColors.background,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ShadcnColors.primary.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    FluentIcons.chat_history_24_filled,
                    color: isEphemeral
                        ? ShadcnColors.primaryForeground
                        : ShadcnColors.mutedForeground,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          AppButton(
            onPressed: () => {onSubmit()},
            text: "Post",
            disabled: !canPost || isPosting,
            isLoading: isPosting,
            height: 40,
          ),
        ],
      ),
    );
  }
}

// ── Post Settings Bottom Sheet ──────────────────────────────────────────────

class _PostSettingsSheet extends StatefulWidget {
  final _ReplyPermission initialPermission;

  const _PostSettingsSheet({required this.initialPermission});

  @override
  State<_PostSettingsSheet> createState() => _PostSettingsSheetState();
}

class _PostSettingsSheetState extends State<_PostSettingsSheet> {
  late _ReplyPermission _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialPermission;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Handle bar ──
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: ShadcnColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Section title ──
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Who can reply and quote',
              style: TextStyle(
                color: ShadcnColors.mutedForeground,
                fontSize: AppFontSizes.bodySmall,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Reply permission options ──
          ..._ReplyPermission.values.map((option) {
            final isSelected = _selected == option;
            return _SettingsRadioTile(
              label: option.label,
              isSelected: isSelected,
              onTap: () => setState(() => _selected = option),
            );
          }),

          const SizedBox(height: 16),

          // ── Done button ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: AppButton(
              text: 'Done',
              fullWidth: true,
              onPressed: () => Navigator.of(context).pop(_selected),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRadioTile extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SettingsRadioTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: ShadcnColors.foreground,
                  fontSize: AppFontSizes.body,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? ShadcnColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? ShadcnColors.primary
                      : ShadcnColors.border,
                  width: isSelected ? 0 : 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: ShadcnColors.primaryForeground,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dashed bubble border painter for ephemeral mode ─────────────────────────

class _DashedBubblePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;
  final double radius;

  _DashedBubblePainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashWidth = 5,
    this.dashGap = 4,
    this.radius = 16,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    // Chat bubble shape: rounded rect with smaller top-left radius
    final path = Path();
    final r = radius;
    final smallR = r * 0.25; // Small radius for the "tail" corner

    path.moveTo(smallR, 0);
    path.lineTo(size.width - r, 0);
    path.arcToPoint(Offset(size.width, r), radius: Radius.circular(r));
    path.lineTo(size.width, size.height - r);
    path.arcToPoint(
      Offset(size.width - r, size.height),
      radius: Radius.circular(r),
    );
    path.lineTo(r, size.height);
    path.arcToPoint(Offset(0, size.height - r), radius: Radius.circular(r));
    path.lineTo(0, smallR);
    path.arcToPoint(Offset(smallR, 0), radius: Radius.circular(smallR));
    path.close();

    // Draw dashed path
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final end = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, end.clamp(0, metric.length)),
          paint,
        );
        distance = end + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBubblePainter oldDelegate) =>
      color != oldDelegate.color ||
      strokeWidth != oldDelegate.strokeWidth ||
      dashWidth != oldDelegate.dashWidth ||
      dashGap != oldDelegate.dashGap ||
      radius != oldDelegate.radius;
}

// ── Ephemeral info notice ───────────────────────────────────────────────────

class _EphemeralNotice extends StatefulWidget {
  @override
  State<_EphemeralNotice> createState() => _EphemeralNoticeState();
}

class _EphemeralNoticeState extends State<_EphemeralNotice> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      decoration: BoxDecoration(
        color: ShadcnColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            child: Text(
              'Ephemeral posts auto-hide from the feed after 24 hours. '
              'Replies will be moved to messages. '
              'Only you can see who liked and replied.',
              style: TextStyle(
                color: ShadcnColors.mutedForeground,
                fontSize: AppFontSizes.caption,
                height: 1.4,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _dismissed = true),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(
                FluentIcons.dismiss_16_regular,
                color: ShadcnColors.mutedForeground,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
