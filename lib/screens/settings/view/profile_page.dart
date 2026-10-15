import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hyper_local/router/app_routes.dart';
import 'package:hyper_local/utils/extensions.dart';
import 'package:hyper_local/utils/widgets/custom_appbar_without_navbar.dart';
import 'package:hyper_local/utils/widgets/custom_image_container.dart';
import 'package:hyper_local/utils/widgets/custom_scaffold.dart';
import 'package:hyper_local/utils/widgets/custom_text.dart';
import 'package:hyper_local/utils/widgets/custom_card.dart';
import 'package:hyper_local/utils/widgets/settings_list_tile.dart';
import 'package:hyper_local/utils/widgets/empty_state_widget.dart';
import 'package:hyper_local/l10n/app_localizations.dart';
import 'package:hyper_local/screens/feed_page/bloc/deliveryboy_status_update_bloc/deliveryboy_status_bloc.dart';
import 'package:hyper_local/screens/feed_page/bloc/deliveryboy_status_update_bloc/deliveryboy_status_state.dart';
import '../../../config/helper.dart';
import '../bloc/profile_bloc/profile_bloc.dart';
import '../bloc/profile_bloc/profile_event.dart';
import '../bloc/profile_bloc/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const LoadProfile());
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.profile,
        showRefreshButton: true,
        onRefreshPressed: () {
          context.read<ProfileBloc>().add(const LoadProfile());
        },
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, profileState) {
          if (profileState.profile != null) {
            final profile = profileState.profile!;
            final profilePictureUrl = profile.user?.profileImage;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<DeliveryBoyStatusBloc, DeliveryBoyStatusState>(
                    builder: (context, statusState) {
                      final isOnline = statusState.isOnline;
                      return CustomCard(
                        padding: EdgeInsets.all(10.w),
                        child: Row(
                          children: [
                            CustomAvatar(imageUrl: profilePictureUrl ?? "", radius: 35.r),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomText(
                                    text: profile.deliveryBoy?.fullName ??
                                        profile.user?.name ??
                                        AppLocalizations.of(context)!.deliveryPartner,
                                    fontSize: sz(16, seprateTabletSize: 12),
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  SizedBox(height: 8.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: profile.deliveryBoy != null
                                          ? (isOnline ? Colors.green : Colors.orange).withValues(
                                              alpha: context.isDarkMode ? 0.3 : 0.15,
                                            )
                                          : Colors.grey.withValues(alpha: context.isDarkMode ? 0.3 : 0.15),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: CustomText(
                                      text: isOnline
                                          ? AppLocalizations.of(context)!.active
                                          : AppLocalizations.of(context)!.inactive,
                                      fontSize: sz(10, seprateTabletSize: 6),
                                      fontWeight: FontWeight.w600,
                                      color: profile.deliveryBoy != null
                                          ? (isOnline
                                              ? (context.isDarkMode ? Colors.green[300] : Colors.green[700])
                                              : (context.isDarkMode ? Colors.orange[300] : Colors.orange[700]))
                                          : (context.isDarkMode ? Colors.grey[400] : Colors.grey[700]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24.h),

                  // Profile Options
                  CustomCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        SettingsListTile(
                          icon: Icons.person_outline,
                          title: AppLocalizations.of(context)!.personalInformation,
                          onTap: () => context.push(AppRoutes.personalInfo),
                          showDivider: true,
                        ),
                        SettingsListTile(
                          icon: Icons.directions_car_outlined,
                          title: AppLocalizations.of(context)!.vehicleInformation,
                          onTap: () => context.push(AppRoutes.vehicleInfo),
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          if (profileState.fetchStatus == ApiStatus.failed) {
            return ErrorStateWidget(
              onRetry: () {
                context.read<ProfileBloc>().add(const LoadProfile());
              },
            );
          }

          // Loading state
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomCard(
                  padding: EdgeInsets.all(10.w),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35.r,
                        backgroundColor: Colors.grey[200],
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(width: 120.w, height: 16.h, color: Colors.grey[200]),
                            SizedBox(height: 8.h),
                            Container(width: 80.w, height: 12.h, color: Colors.grey[200]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
                CustomCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      SettingsListTile(
                        icon: Icons.person_outline,
                        title: AppLocalizations.of(context)!.personalInformation,
                        onTap: null,
                        showDivider: true,
                      ),
                      SettingsListTile(
                        icon: Icons.phone_outlined,
                        title: AppLocalizations.of(context)!.contactInformation,
                        onTap: null,
                        showDivider: true,
                      ),
                      SettingsListTile(
                        icon: Icons.directions_car_outlined,
                        title: AppLocalizations.of(context)!.vehicleInformation,
                        onTap: null,
                        showDivider: true,
                      ),
                      SettingsListTile(
                        icon: Icons.verified_user_outlined,
                        title: AppLocalizations.of(context)!.verificationStatus,
                        onTap: null,
                        showDivider: true,
                      ),
                      SettingsListTile(
                        icon: Icons.document_scanner_outlined,
                        title: AppLocalizations.of(context)!.documents,
                        onTap: null,
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
