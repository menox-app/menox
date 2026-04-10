import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/widgets/app_button.dart';
import 'package:flutter_core/core/ui/widgets/app_icon_button.dart';
import 'package:flutter_core/core/ui/widgets/app_text_field.dart';
import 'package:flutter_core/features/auth/presentation/providers/signup_provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class RegisterPage extends HookConsumerWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = CupertinoTheme.of(context);
    final pageController = usePageController();
    final currentStep = useState(0);

    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final firstNameController = useTextEditingController();
    final lastNameController = useTextEditingController();
    final usernameController = useTextEditingController();

    final emailError = useState<String?>(null);
    final passwordError = useState<String?>(null);
    final nameError = useState<String?>(null);
    final usernameError = useState<String?>(null);

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

    void validateName() {
      final firstNameVal = FormBuilderValidators.required()(firstNameController.text);
      final lastNameVal = FormBuilderValidators.required()(lastNameController.text);
      nameError.value = firstNameVal ?? lastNameVal;
    }

    void validateUsername(String value) {
      usernameError.value = FormBuilderValidators.compose([
        FormBuilderValidators.required(),
        FormBuilderValidators.minLength(3),
      ])(value);
    }

    void nextStep() {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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

    final signUpNotifier = ref.read(signUpProvider.notifier);

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
            _RegisterStepLayout(
              title: "What's your email?",
              theme: theme,
              isContinueEnabled:
                  emailError.value == null && emailController.text.isNotEmpty,
              onContinue: () {
                signUpNotifier.updateEmail(emailController.text);
                nextStep();
              },
              child: AppTextField(
                hintText: "Email address",
                controller: emailController,
                prefixIcon: CupertinoIcons.mail,
                keyboardType: TextInputType.emailAddress,
                autofocus: true,
                errorText: emailError.value,
                onChanged: validateEmail,
              ),
            ),
            // Step 2: Password
            _RegisterStepLayout(
              title: "What's your password?",
              theme: theme,
              isContinueEnabled: passwordError.value == null &&
                  passwordController.text.isNotEmpty,
              onContinue: () {
                signUpNotifier.updatePassword(passwordController.text);
                nextStep();
              },
              child: Column(
                children: [
                  AppTextField(
                    hintText: "Password",
                    controller: passwordController,
                    isPassword: true,
                    prefixIcon: CupertinoIcons.lock,
                    autofocus: true,
                    errorText: passwordError.value,
                    onChanged: validatePassword,
                  ),
                  const SizedBox(height: 12),
                  _buildPasswordHint(theme),
                ],
              ),
            ),
            // Step 3: Name
            _RegisterStepLayout(
              title: "What's your name?",
              theme: theme,
              isContinueEnabled: nameError.value == null &&
                  firstNameController.text.isNotEmpty &&
                  lastNameController.text.isNotEmpty,
              onContinue: () {
                signUpNotifier.updateName(
                    firstNameController.text, lastNameController.text);
                // Pre-fill username based on name
                usernameController.text = ref.read(signUpProvider).username;
                nextStep();
              },
              child: Column(
                children: [
                  AppTextField(
                    hintText: "First Name",
                    controller: firstNameController,
                    prefixIcon: CupertinoIcons.person,
                    autofocus: true,
                    onChanged: (_) => validateName(),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    hintText: "Last Name",
                    controller: lastNameController,
                    prefixIcon: CupertinoIcons.person,
                    onChanged: (_) => validateName(),
                    errorText: nameError.value,
                  ),
                ],
              ),
            ),
            // Step 4: Username
            _RegisterStepLayout(
              title: "Pick a username",
              theme: theme,
              continueText: "Finish",
              isContinueEnabled: usernameError.value == null &&
                  usernameController.text.isNotEmpty,
              onContinue: () {
                signUpNotifier.updateUsername(usernameController.text);
                context.go('/pokemon');
              },
              child: AppTextField(
                hintText: "Username",
                controller: usernameController,
                prefixIcon: CupertinoIcons.at,
                autofocus: true,
                errorText: usernameError.value,
                onChanged: validateUsername,
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

class _RegisterStepLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onContinue;
  final String continueText;
  final CupertinoThemeData theme;
  final bool isContinueEnabled;

  const _RegisterStepLayout({
    required this.title,
    required this.child,
    required this.onContinue,
    this.continueText = "Continue",
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
