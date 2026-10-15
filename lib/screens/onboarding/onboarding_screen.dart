import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_local/config/colors.dart';
import 'package:hyper_local/config/global.dart';
import 'package:hyper_local/router/app_routes.dart';
import 'package:hyper_local/utils/extensions.dart';
import 'package:hyper_local/utils/widgets/custom_button.dart';
import 'package:hyper_local/utils/widgets/custom_image_container.dart';
import 'package:hyper_local/utils/widgets/custom_scaffold.dart';
import 'package:hyper_local/utils/widgets/custom_text.dart';
import 'package:hyper_local/l10n/app_localizations.dart';
import 'package:hyper_local/config/app_images.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _completeOnboarding() async {
    // Saves string / status in hive indicating onboarding is completed
    await Global.setOnboardingComplete(true);
    if (mounted) {
      context.go(AppRoutes.login);
    }
  }

  void _onNextPressed(int totalPages) {
    if (_currentPage < totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.isDarkMode;
    const Color activeIndicatorColor = AppColors.primaryColor;
    final Color inactiveIndicatorColor =
        isDark ? AppColors.darkBorderColor : AppColors.borderColor;
    final localizations = AppLocalizations.of(context)!;

    final List<OnboardingPageData> pages = [
      OnboardingPageData(
        image: AppImages.onboard1,
        title: localizations.onboardAcceptOrdersTitle,
        subtitle: localizations.onboardAcceptOrdersSubtitle,
      ),
      OnboardingPageData(
        image: AppImages.onboard2,
        title: localizations.onboardTrackEarningsTitle,
        subtitle: localizations.onboardTrackEarningsSubtitle,
      ),

      //   OnboardingPageData(
      //   image: AppImages.onboard3, // Rider/Inactive graphic
      //   title: localizations.onboardNavigateEasilyTitle,
      //  subtitle: localizations.onboardNavigateEasilySubtitle,
      //),
    ];

    return CustomScaffold(
      backgroundColor:
          isDark ? AppColors.darkBackgroundColor : AppColors.backgroundColor,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  spacing: 5,
                  children: [
                    // PageView taking top-half and main area
                    Container(
                      height: 500,
                      padding: const EdgeInsets.all(10),
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (int page) {
                          setState(() {
                            _currentPage = page;
                          });
                        },
                        itemCount: pages.length,
                        itemBuilder: (context, index) {
                          final page = pages[index];
                          return CustomImageContainer(
                            imagePath: page.image,
                            fit: BoxFit.contain,
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        spacing: 5,
                        children: [
                          CustomText(
                            text: pages[_currentPage].title,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            textAlign: TextAlign.center,
                            color: isDark ? Colors.white : AppColors.textColor,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: CustomText(
                              text: pages[_currentPage].subtitle,
                              textAlign: TextAlign.center,
                              fontWeight: FontWeight.w500,
                              color:
                                  isDark
                                      ? AppColors.darkTextSecondaryColor
                                      : AppColors.textSecondaryColor,
                            ),
                          ),
                          const SizedBox(height: 5),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              pages.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: EdgeInsets.symmetric(horizontal: 4.w),
                                height: 6.h,
                                width: _currentPage == index ? 24.w : 6.w,
                                decoration: BoxDecoration(
                                  color:
                                      _currentPage == index
                                          ? activeIndicatorColor
                                          : inactiveIndicatorColor,
                                  borderRadius: BorderRadius.circular(3.r),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Next/Get Started Button
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: CustomButton(
                        text:
                            _currentPage == pages.length - 1
                                ? localizations.getStarted
                                : localizations.next,
                        onPressed: () => _onNextPressed(pages.length),
                        width: double.infinity,
                        borderRadius: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class OnboardingPageData {
  final String image;
  final String title;
  final String subtitle;

  OnboardingPageData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}
