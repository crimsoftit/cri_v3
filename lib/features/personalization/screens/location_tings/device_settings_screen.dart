import 'package:cri_v3/common/widgets/appbar/app_bar.dart';
import 'package:cri_v3/common/widgets/custom_shapes/containers/primary_header_container.dart';
import 'package:cri_v3/common/widgets/list_tiles/menu_tile.dart';
import 'package:cri_v3/common/widgets/loaders/default_loader.dart';
import 'package:cri_v3/data/repos/auth/auth_repo.dart';
import 'package:cri_v3/features/personalization/controllers/location_controller.dart';
import 'package:cri_v3/features/personalization/screens/location_tings/widgets/device_settings_btn.dart';
import 'package:cri_v3/main.dart';
import 'package:cri_v3/services/location_services.dart';
import 'package:cri_v3/services/permission_provider.dart';
import 'package:cri_v3/utils/constants/colors.dart';
import 'package:cri_v3/utils/constants/sizes.dart';
import 'package:cri_v3/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:permission_handler/permission_handler.dart';

class CDeviceSettingsScreen extends StatefulWidget {
  const CDeviceSettingsScreen({super.key});

  @override
  State<CDeviceSettingsScreen> createState() => _CLocationSettingsScreenState();
}

class _CLocationSettingsScreenState extends State<CDeviceSettingsScreen> {
  /// -- variables --

  late StreamController<PermissionStatus> _permissionStatusStream;
  late StreamController<AppLifecycleState> _appCycleStateStream;
  late final AppLifecycleListener _listener;
  bool geoSwitchIsOn = false;

  final CLocationController locationController = Get.put<CLocationController>(
    CLocationController(),
  );

  @override
  void initState() {
    super.initState();
    _permissionStatusStream = StreamController<PermissionStatus>();
    _appCycleStateStream = StreamController<AppLifecycleState>();
    _listener = AppLifecycleListener(
      onStateChange: _onStateChange,
      onResume: _onResume,
      onInactive: _onInactive,
      onHide: _onHide,
      onShow: _onShow,
      onPause: _onPause,
      onRestart: _onRestart,
      onDetach: _onDetach,
    );
    _appCycleStateStream.sink.add(SchedulerBinding.instance.lifecycleState!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkPermissionAndListenLocation();
    });

    if (PermissionProvider.locationServiceIsOn) {
      setState(() {
        geoSwitchIsOn = true;
      });
      CLocationServices.instance.getUserLocation(
        locationController: locationController,
      );
    }
    // CLocationServices.instance
    //     .getUserLocation(locationController: locationController);
  }

  void _onStateChange(AppLifecycleState state) =>
      _appCycleStateStream.sink.add(state);

  void _onResume() {
    log('onResume');
    if (PermissionProvider.permissionDialogRoute != null &&
        PermissionProvider.permissionDialogRoute!.isActive) {
      Navigator.of(
        globalNavigatorKey.currentContext!,
      ).removeRoute(PermissionProvider.permissionDialogRoute!);
    }
    Future.delayed(const Duration(milliseconds: 250), () async {
      checkPermissionAndListenLocation();
    });

    if (PermissionProvider.locationServiceIsOn) {
      setState(() {
        geoSwitchIsOn = true;
      });
      CLocationServices.instance.getUserLocation(
        locationController: locationController,
      );
    }
    // CLocationServices.instance
    //     .getUserLocation(locationController: locationController);
  }

  void _onInactive() => log('onInactive');

  void _onHide() => log('onHide');

  void _onShow() => log('onShow');

  void _onPause() => log('onPause');

  void _onRestart() => log('onRestart');

  void _onDetach() => log('onDetach');

  @override
  void dispose() {
    _listener.dispose();
    _permissionStatusStream.close();
    _appCycleStateStream.close();
    super.dispose();
  }

  void checkPermissionAndListenLocation() {
    PermissionProvider.handleLocationPermission().then((_) {
      _permissionStatusStream.sink.add(PermissionProvider.locationPermission);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = CHelperFunctions.isDarkMode(context);

    return Scaffold(
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: CHelperFunctions.screenHeight() * .95,
          child: Column(
            children: [
              // -- header --
              CPrimaryHeaderContainer(
                child: Column(
                  children: [
                    // app bar
                    CAppBar(
                      title: Text(
                        'app settings',
                        style: Theme.of(
                          context,
                        ).textTheme.headlineSmall!.apply(color: CColors.white),
                      ),
                      backIconAction: () {
                        //SystemNavigator.pop();
                        Navigator.of(context, rootNavigator: true).pop(context);
                        //Get.back();
                      },
                      showBackArrow: true,
                      backIconColor: CColors.white,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: StreamBuilder<PermissionStatus>(
                    stream: _permissionStatusStream.stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const DefaultLoaderScreen(); // Display a loading indicator when waiting for data
                      } else if (snapshot.hasError) {
                        return Text(
                          'Error: ${snapshot.error}',
                        ); // Display an error message if an error occurs
                      } else if (!snapshot.hasData) {
                        return const Text(
                          'No Data Available',
                        ); // Display a message when no data is available
                      } else {
                        return Column(
                          children: [
                            Visibility(
                              visible: false,
                              child: Text(
                                'location service: ${PermissionProvider.locationServiceIsOn ? "On" : "Off"}\n${snapshot.data}',
                                // style: const TextStyle(fontSize: 24),
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge!.apply(),
                              ),
                            ),
                            const SizedBox(height: CSizes.spaceBtnSections),
                            CMenuTile(
                              icon: Iconsax.location,
                              title: 'enable location services',
                              subTitle:
                                  'rIntel requires location info to protect buyers & sellers',
                              trailing: Switch(
                                value: PermissionProvider.locationServiceIsOn,
                                activeThumbColor: CColors.rBrown,
                                onChanged: (value) {
                                  setState(() {
                                    PermissionProvider.locationServiceIsOn =
                                        value;
                                  });

                                  if (geoSwitchIsOn) {
                                    CLocationServices.instance.getUserLocation(
                                      locationController: locationController,
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: StreamBuilder<AppLifecycleState>(
                    stream: _appCycleStateStream.stream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const DefaultLoaderScreen(); // Display a loading indicator when waiting for data
                      } else if (snapshot.hasError) {
                        return Text(
                          'Error: ${snapshot.error}',
                        ); // Display an error message if an error occurs
                      } else if (!snapshot.hasData) {
                        return const Text(
                          'No data available',
                        ); // Display a message when no data is available
                      } else {
                        return Obx(() {
                          //if (locationController.processingLocationAccess.value)
                          if (locationController
                                      .processingLocationAccess
                                      .value &&
                                  locationController.uAddress.value == '' ||
                              locationController.uCurCode.value == '') {
                            if (!geoSwitchIsOn) {
                              return const DeviceSettingsBtn();
                            } else {
                              return const DefaultLoaderScreen();
                            }
                          }

                          if (geoSwitchIsOn) {
                            CLocationServices.instance.getUserLocation(
                              locationController: locationController,
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Visibility(
                                  visible: false,
                                  child: Column(
                                    children: [
                                      Text(
                                        'latitude: ${locationController.userLocation.value!.latitude ?? ''}',
                                      ),
                                      Text(
                                        'longitude: ${locationController.userLocation.value!.longitude ?? ''}',
                                      ),
                                      Text(
                                        'user country: ${locationController.uCountry.value}',
                                      ),
                                      Text(
                                        'user Address: ${locationController.uAddress.value}',
                                      ),
                                      Text(
                                        'user currency code: ${locationController.uCurCode.value}',
                                      ),
                                      Text(
                                        '${snapshot.data}',
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ],
                                  ),
                                ),
                                const DeviceSettingsBtn(),
                                // const SizedBox(
                                //   height: CSizes.defaultSpace,
                                // ),
                                Center(
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Iconsax.logout,
                                        size: 28.0,
                                        color: CColors.primaryBrown,
                                      ),
                                      const SizedBox(
                                        width: CSizes.spaceBtnInputFields,
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          AuthRepo.instance.logout();
                                        },
                                        child: Text(
                                          'log out',
                                          style: TextStyle(
                                            color: isDarkTheme
                                                ? CColors.grey
                                                : CColors.darkGrey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
