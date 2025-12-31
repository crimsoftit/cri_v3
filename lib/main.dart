import 'package:cri_v3/api/mpesa_tings/creds/mpesa_api_creds.dart';
import 'package:cri_v3/app.dart';
import 'package:cri_v3/data/repos/auth/auth_repo.dart';
import 'package:cri_v3/firebase_options.dart';
import 'package:cri_v3/services/notification_services.dart';
import 'package:cri_v3/utils/db/sqflite/db_helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mpesa_flutter_plugin/initializer.dart';
import 'package:timezone/data/latest.dart' as tz;

final globalNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  /// -- todo: add widgets binding --
  final WidgetsBinding widgetsBinding =
      WidgetsFlutterBinding.ensureInitialized();

  /// -- todo: initialize firebase --
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).then((FirebaseApp value) => Get.put(AuthRepo()));

  MpesaFlutterPlugin.setConsumerKey(CMpesaApiCreds.consumerKey);
  MpesaFlutterPlugin.setConsumerSecret(CMpesaApiCreds.consumerSecret);

  /// -- initialize spreadsheets --
  // if (CNetworkManager.instance.hasConnection.value) {
  //   await StoreSheetsApi.initSpreadSheets();
  // }
  //await StoreSheetsApi.initSpreadSheets();

  /// -- initialize awesome notifications --
  await CNotificationServices.initializeNotifications();

  /// -- init local storage (GetX Local Storage) --
  await GetStorage.init();

  /// -- remove # sign from url --
  //setPathUrlStrategy();

  tz.initializeTimeZones();

  /// -- todo: await native splash --
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // -- init sqflite db --
  DbHelper dbHelper = DbHelper.instance;
  await dbHelper.openDb();

  /// -- todo: load all the material design, themes, localizations, bindings, etc. --
  runApp(const App());
}
