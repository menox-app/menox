import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_core/core/ui/widgets/app_icon_button.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/widgets/app_button.dart';
import 'package:flutter_core/core/ui/widgets/app_text_field.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:form_builder_validators/form_builder_validators.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = CupertinoTheme.of(context);
    final pageController = usePageController();
    final currentStep = useState(0);
    final emailError = useState<String?>(null);
    final passwordError = useState<String?>(null);

    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    void validateEmail(String value) {
      emailError.value = FormBuilderValidators.compose([
        FormBuilderValidators.required(),
        FormBuilderValidators.email(),
      ])(value);
    }

    void validatePassword(String value) {
      passwordError.value = FormBuilderValidators.compose([
        FormBuilderValidators.required(),
        FormBuilderValidators.minLength(8),
      ])(value);
    }

    void nextStep() {
      validateEmail(emailController.text);
      if (emailError.value == null && emailController.text.isNotEmpty) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }

    void previousStep() {
      if (currentStep.value > 0) {
        pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        context.pop();
      }
    }

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        border: null,
        leading: AppIconButton(
          size: AppButtonSize.sm,
          variant: AppButtonVariant.secondary,
          icon: CupertinoIcons.back,
          onPressed: previousStep,
        ),
      ),
      child: SafeArea(
        child: PageView(
          controller: pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (step) => currentStep.value = step,
          children: [
            // Step 1: Email
            _LoginStepLayout(
              title: "What's your email?",
              onContinue: nextStep,
              showLegal: true,
              theme: theme,
              isContinueEnabled:
                  emailError.value == null && emailController.text.isNotEmpty,
              child: Column(
                children: [
                  AppTextField(
                    hintText: "Email address",
                    controller: emailController,
                    prefixIcon: CupertinoIcons.mail,
                    keyboardType: TextInputType.emailAddress,
                    autofocus: true,
                    errorText: emailError.value,
                    onChanged: validateEmail,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    text: "I forgot my account",
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.sm,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            // Step 2: Password
            _LoginStepLayout(
              title: "What's your password?",
              continueText: "Login",
              isContinueEnabled:
                  passwordError.value == null && passwordController.text.isNotEmpty,
              onContinue: () {
                validatePassword(passwordController.text);
                if (passwordError.value == null &&
                    passwordController.text.isNotEmpty) {
                  // Execute Login API call here
                  // context.go('/pokemon');
                }
              },
              theme: theme,
              child: Column(
                children: [
                  AppTextField(
                    hintText: "Password",
                    controller: passwordController,
                    prefixIcon: CupertinoIcons.lock,
                    isPassword: true,
                    autofocus: true,
                    errorText: passwordError.value,
                    onChanged: validatePassword,
                  ),
                  const SizedBox(height: 12),
                  _buildPasswordHint(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordHint(CupertinoThemeData theme) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: theme.textTheme.textStyle.copyWith(
          fontSize: 13,
          color: ShadcnColors.mutedForeground,
        ),
        children: [
          const TextSpan(text: 'Your password must be at least '),
          TextSpan(
            text: '8 characters',
            style: const TextStyle(
              color: ShadcnColors.primary,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = () {},
          ),
        ],
      ),
    );
  }
}

class _LoginStepLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onContinue;
  final String continueText;
  final bool showLegal;
  final CupertinoThemeData theme;
  final bool isContinueEnabled;

  const _LoginStepLayout({
    required this.title,
    required this.child,
    required this.onContinue,
    this.continueText = "Continue",
    this.showLegal = false,
    required this.theme,
    this.isContinueEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          Text(
            title,
            style: theme.textTheme.navLargeTitleTextStyle.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          child,
          const Spacer(flex: 3),
          if (showLegal) ...[
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: theme.textTheme.textStyle.copyWith(
                  fontSize: 13,
                  color: ShadcnColors.mutedForeground,
                ),
                children: [
                  const TextSpan(
                    text: 'By tapping Continue, you agree to our ',
                  ),
                  TextSpan(
                    text: 'Terms of Service',
                    style: const TextStyle(
                      color: ShadcnColors.foreground,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Logic for Terms of Service
                      },
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(
                      color: ShadcnColors.foreground,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        // Logic for Privacy Policy
                      },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          AppButton(
            text: continueText,
            fullWidth: true,
            size: AppButtonSize.lg,
            disabled: !isContinueEnabled,
            onPressed: onContinue,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
