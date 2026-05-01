import 'package:flutter/cupertino.dart';
import 'package:flutter_core/core/theme/app_theme.dart';
import 'package:flutter_core/core/ui/widgets/app_button.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_core/core/ui/assets/app_icons.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          child: Column(
            children: [
              // Illustration
              SizedBox(
                height: 300,
                child: SvgPicture.asset(
                  'assets/illustrations/welcome.svg',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 32),
              // App Name & Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: SvgPicture.asset(
                      AppIcons.appLogo,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Menox",
                    style: TextStyle(
                      fontSize: AppFontSizes.largeTitle,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Tagline
              const Text(
                "Live memes from your friends,\non your home screen.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFontSizes.input,
                  fontWeight: FontWeight.w500,
                  color: ShadcnColors.mutedForeground,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              AppButton(
                text: "Create an account",
                size: AppButtonSize.lg,
                onPressed: () => context.push('/register'),
              ),
              const SizedBox(height: 12),
              AppButton(
                text: "Sign In",
                size: AppButtonSize.lg,
                variant: AppButtonVariant.ghost,
                onPressed: () => context.push('/login'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
