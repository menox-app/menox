import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_core/core/apis/app/index.dart' show AppApi;
import 'package:flutter_core/core/apis/app/interfaces/auth.dart';
import 'package:flutter_core/core/apis/base/interfaces/response.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/widgets/app_button.dart';
import 'package:flutter_core/core/ui/widgets/app_icon_button.dart';
import 'package:flutter_core/core/ui/widgets/app_image.dart';
import 'package:flutter_core/core/ui/widgets/app_text_field.dart';
import 'package:flutter_core/features/auth/hooks/auth_provider.dart';
import 'package:flutter_core/features/auth/hooks/signup_provider.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_query/flutter_query.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_core/core/constants/avatar_constants.dart';

class RegisterScreen extends HookConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = CupertinoTheme.of(context);
    final pageController = usePageController();
    final currentStep = useState(0);
    final apiClient = AppApi.instance.auth;

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
      final firstNameVal = FormBuilderValidators.required()(
        firstNameController.text,
      );
      final lastNameVal = FormBuilderValidators.required()(
        lastNameController.text,
      );
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

    final signUpMutation =
        useMutation<
          BaseResponse<SignUpResponse>,
          dynamic,
          ISignUpRequest,
          void
        >(
          (input, ctx) => apiClient.signUp(input),
          onSuccess: (data, variables, onMutateResult, mutationContext) {
            ref
                .read(authProvider.notifier)
                .login(data.data.token, data.data.refreshToken);
            signUpNotifier.reset();
          },
          onError: (error, variables, onMutateResult, mutationContext) {
            showCupertinoDialog(
              context: context,
              builder: (ctx) => CupertinoAlertDialog(
                title: const Text('Registration Failed'),
                content: Text(error.toString()),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('OK'),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            );
          },
        );

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
                validateEmail(emailController.text);
                if (emailError.value == null &&
                    emailController.text.isNotEmpty) {
                  signUpNotifier.updateEmail(emailController.text);
                  nextStep();
                }
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
              isContinueEnabled:
                  passwordError.value == null &&
                  passwordController.text.isNotEmpty,
              onContinue: () {
                validatePassword(passwordController.text);
                if (passwordError.value == null &&
                    passwordController.text.isNotEmpty) {
                  signUpNotifier.updatePassword(passwordController.text);
                  nextStep();
                }
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
              isContinueEnabled:
                  nameError.value == null &&
                  firstNameController.text.isNotEmpty &&
                  lastNameController.text.isNotEmpty,
              onContinue: () {
                validateName();
                if (nameError.value == null &&
                    firstNameController.text.isNotEmpty &&
                    lastNameController.text.isNotEmpty) {
                  signUpNotifier.updateName(
                    firstNameController.text,
                    lastNameController.text,
                  );
                  usernameController.text = ref.read(signUpProvider).username;
                  nextStep();
                }
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
              isContinueEnabled:
                  usernameError.value == null &&
                  usernameController.text.isNotEmpty,
              onContinue: () {
                validateUsername(usernameController.text);
                if (usernameError.value == null &&
                    usernameController.text.isNotEmpty) {
                  signUpNotifier.updateUsername(usernameController.text);
                  nextStep();
                }
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

            // Step 5: Avatar Selection - Final step
            _RegisterStepLayout(
              title: "Pick Your Avatar",
              theme: theme,
              continueText: "Finish",
              isLoading: signUpMutation.isPending,
              onContinue: () {
                final state = ref.read(signUpProvider);
                signUpMutation.mutate(
                  ISignUpRequest(
                    body: SignUpBody(
                      email: state.email,
                      password: state.password,
                      username: state.username,
                      displayName: state.displayName,
                      avatarUrl: state.avatar,
                    ),
                  ),
                );
              },
              child: Column(
                children: [
                  Text(
                    "Choose one to get started",
                    style: theme.textTheme.textStyle.copyWith(
                      color: ShadcnColors.mutedForeground,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Large Preview
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ShadcnColors.primary.withValues(
                                alpha: 0.1,
                              ),
                              width: 8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: ShadcnColors.primary.withValues(
                                  alpha: 0.05,
                                ),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: AppImage(
                                key: ValueKey(ref.watch(signUpProvider).avatar),
                                url: ref.watch(signUpProvider).avatar,
                                fit: BoxFit.cover,
                                backgroundColor: ShadcnColors.muted,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: AppIconButton(
                            icon: CupertinoIcons.camera_fill,
                            variant: AppButtonVariant.secondary,
                            onPressed: () async {
                              final picker = ImagePicker();
                              final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                ref
                                    .read(signUpProvider.notifier)
                                    .updateAvatar(image.path);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Thumbnails Row
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: AvatarConstants.defaultAvatars.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final avatarUrl = AvatarConstants.defaultAvatars[index];
                        final isSelected =
                            ref.watch(signUpProvider).avatar == avatarUrl;

                        return GestureDetector(
                          onTap: () => ref
                              .read(signUpProvider.notifier)
                              .updateAvatar(avatarUrl),
                          child: Stack(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? ShadcnColors.primary
                                        : ShadcnColors.border,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: AppImage(
                                    url: avatarUrl,
                                    fit: BoxFit.cover,
                                    backgroundColor: ShadcnColors.muted,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: ShadcnColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.check_mark,
                                      color: ShadcnColors.primaryForeground,
                                      size: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
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
  final bool isLoading;

  const _RegisterStepLayout({
    required this.title,
    required this.child,
    required this.onContinue,
    this.continueText = "Continue",
    required this.theme,
    this.isContinueEnabled = true,
    this.isLoading = false,
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
            isLoading: isLoading,
            onPressed: onContinue,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
