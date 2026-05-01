import 'package:flutter/cupertino.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_core/core/theme/app_theme.dart';

class AppTextField extends StatefulWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final Widget? prefix;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final bool autofocus;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  const AppTextField({
    super.key,
    required this.hintText,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.prefix,
    this.suffixIcon,
    this.validator,
    this.autofocus = false,
    this.errorText,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CupertinoTextField(
          controller: widget.controller,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          enabled: widget.enabled,
          onChanged: widget.onChanged,
          placeholder: widget.hintText,
          placeholderStyle: const TextStyle(
            color: ShadcnColors.mutedForeground,
            fontSize: AppFontSizes.input,
            letterSpacing: -0.4,
          ),
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: ShadcnColors.input,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.errorText != null
                  ? ShadcnColors.destructive
                  : (_isFocused ? ShadcnColors.ring : ShadcnColors.border),
              width: 1.5,
            ),
          ),
          prefix:
              widget.prefix ??
              (widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 14),
                      child: Icon(
                        widget.prefixIcon,
                        size: 20,
                        color: ShadcnColors.mutedForeground,
                      ),
                    )
                  : null),
          suffix:
              widget.suffixIcon ??
              (widget.isPassword
                  ? CupertinoButton(
                      padding: const EdgeInsets.only(right: 10),
                      onPressed: () =>
                          setState(() => _obscureText = !_obscureText),
                      minimumSize: const Size(0, 0),
                      child: Icon(
                        _obscureText
                            ? FluentIcons.eye_off_24_regular
                            : FluentIcons.eye_24_regular,
                        size: 20,
                        color: ShadcnColors.mutedForeground,
                      ),
                    )
                  : null),
          style: const TextStyle(
            color: ShadcnColors.foreground,
            fontSize: AppFontSizes.input,
            letterSpacing: -0.4,
          ),
          cursorColor: ShadcnColors.primary,
          cursorWidth: 2,
          cursorRadius: const Radius.circular(2),
        ),

        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final offsetAnimation =
                  Tween<Offset>(
                    begin: const Offset(0, -0.2),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  );

              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: offsetAnimation, child: child),
              );
            },
            child: widget.errorText != null
                ? Container(
                    key: ValueKey<String>(widget.errorText!),
                    width: double.infinity,
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      widget.errorText!,
                      style: const TextStyle(
                        color: ShadcnColors.destructive,
                        fontSize: AppFontSizes.caption,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  )
                : const SizedBox(key: ValueKey('none'), width: double.infinity),
          ),
        ),
      ],
    );
  }
}
