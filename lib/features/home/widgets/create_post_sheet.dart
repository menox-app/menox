import 'package:flutter/cupertino.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_core/core/hooks/use_auth.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/widgets/app_image.dart';
import 'package:flutter_core/core/ui/widgets/app_spinner.dart';
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
      Navigator.pop(context);
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
      Navigator.pop(context);
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
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() => _isPosting = false);

    await showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Draft ready'),
        content: const Text(
          'Post composer is ready. Next step is wiring upload/create API.',
        ),
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
      height: 64,
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
            'New post',
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
  final TextEditingController contentController;
  final FocusNode focusNode;
  final List<_ComposerAttachment> attachments;
  final ValueChanged<int> onRemoveAttachment;
  final VoidCallback onPickMedia;

  const _ComposerBody({
    required this.contentController,
    required this.focusNode,
    required this.attachments,
    required this.onRemoveAttachment,
    required this.onPickMedia,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = useAuth(ref).user;
    final username = user?.username.isNotEmpty == true
        ? user!.username
        : 'memox_user';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 46,
            child: Column(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ShadcnColors.border, width: 0.5),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: AppImage.avatar(
                    url: user?.avatarUrl,
                    size: 46,
                    backgroundColor: ShadcnColors.secondary,
                  ),
                ),
                Container(
                  width: 2,
                  height: 92,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  color: ShadcnColors.border,
                ),
                Opacity(
                  opacity: 0.35,
                  child: AppImage.avatar(
                    url: user?.avatarUrl,
                    size: 22,
                    backgroundColor: ShadcnColors.secondary,
                    errorIconSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    const SizedBox(width: 8),
                    const Icon(
                      FluentIcons.chevron_right_24_regular,
                      color: ShadcnColors.mutedForeground,
                      size: 17,
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
                if (attachments.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _AttachmentStrip(
                    attachments: attachments,
                    onRemoveAttachment: onRemoveAttachment,
                  ),
                ],
                const SizedBox(height: 12),
                _ComposerToolbar(onPickMedia: onPickMedia),
                const SizedBox(height: 28),
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
          icon: FluentIcons.attach_24_regular,
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
    return CupertinoButton(
      minimumSize: const Size.square(38),
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Icon(icon, color: ShadcnColors.mutedForeground, size: 26),
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

  const _ComposerBottomBar({
    required this.canPost,
    required this.isPosting,
    required this.onSubmit,
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
        children: [
          const Icon(
            FluentIcons.options_24_regular,
            color: ShadcnColors.mutedForeground,
            size: 26,
          ),
          const SizedBox(width: 10),
          const Text(
            'Reply options',
            style: TextStyle(
              color: ShadcnColors.mutedForeground,
              fontSize: AppFontSizes.bodySmall,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Container(
            width: 66,
            height: 46,
            decoration: BoxDecoration(
              color: ShadcnColors.secondary,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 42,
                height: 42,
                margin: const EdgeInsets.only(left: 2),
                decoration: BoxDecoration(
                  color: ShadcnColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: ShadcnColors.border),
                ),
                child: const Icon(
                  FluentIcons.person_circle_24_regular,
                  color: ShadcnColors.mutedForeground,
                  size: 25,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          CupertinoButton(
            minimumSize: const Size(0, 40),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            color: canPost ? ShadcnColors.primary : const Color(0xFFC7C7CC),
            borderRadius: BorderRadius.circular(24),
            onPressed: canPost && !isPosting ? onSubmit : null,
            child: isPosting
                ? const AppSpinner(
                    size: 18,
                    color: ShadcnColors.primaryForeground,
                  )
                : const Text(
                    'Post',
                    style: TextStyle(
                      color: ShadcnColors.primaryForeground,
                      fontSize: AppFontSizes.body,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
