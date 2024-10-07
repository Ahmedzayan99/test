import 'dart:io';

import 'package:project1/app/routes.dart';
import 'package:project1/ui/screen/home/home_screen.dart';
import 'package:project1/utils/labelKeys.dart';
import 'package:project1/ui/screen/ticket/chat_screen.dart';
import 'package:project1/utils/uiUtils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

backgroundMessage(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print(
      'notification(${notificationResponse.id}) action tapped: ${notificationResponse.actionId} with payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}

class NotificationUtility{
  late BuildContext context;
  NotificationUtility({required this.context});
  void initLocalNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@drawable/notification_icon');
    /* final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification); */

        final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
      },
    );

    //Android 13 or higher
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    /* flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (String? payload) async {
      
    }); */

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            selectNotificationPayload(notificationResponse.payload!);

            break;
          case NotificationResponseType.selectedNotificationAction:
            print(
                "notification-action-id--->${notificationResponse.actionId}==${notificationResponse.payload}");

            break;
        }
      },
      onDidReceiveBackgroundNotificationResponse: backgroundMessage,
    );
    _requestPermissionsForIos();
    //_configureLocalTimeZone();
  }

  /* Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  } */

  /* Future<void> registerMessage({
    required int hour,
    required int minutes,
    required message,
  }) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minutes,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'flutter_local_notifications',
      message,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'com.wrteam.project1', //channel id
        'project1', //channel name
        channelDescription: 'project1', //channel description
          importance: Importance.max,
          priority: Priority.high,
          ongoing: false,
          styleInformation: BigTextStyleInformation(message),
          icon: '@drawable/notification_icon',
        ),
        iOS: const DarwinNotificationDetails(
          badgeNumber: 1,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  } */

  selectNotificationPayload(String? payload) async {
    print("payload:$payload");
    if (payload != null) {

        List<String> pay = payload.split(",");
        //
        if (pay[0] == "products") {
        } else if (pay[0] == "categories") {
          Navigator.of(context).pushNamed(Routes.cuisineDetail, arguments: {'categoryId': pay[1], 'name': UiUtils.getTranslatedLabel(context, deliciousCuisineLabel)});
        } else if (pay[0] == "wallet") {
          Navigator.of(context).pushNamed(Routes.wallet);
        } else if (pay[0] == "place_order" || pay[0] == "order"){//'order') {
          Navigator.of(context).pushNamed(Routes.orderDetail, arguments: {
            'id': pay[1],
            'riderId': "",
            'riderName': "",
            'riderRating': "",
            'riderImage': "",
            'riderMobile': "",
            'riderNoOfRating': "",
            'isSelfPickup': "",
            'from': 'orderDetail'
          });
        } else if (pay[0] == "ticket_message") {
          Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => ChatScreen(
                      id: pay[1],
                      status: "",
                    )),
          );
        } else if (pay[0] == "ticket_status") {
          Navigator.of(context).pushNamed(Routes.ticket);
        } else {
          Navigator.of(context).pushReplacementNamed(Routes.home/* , arguments: {'id': 0} */);
        }
      }
}

  Future<void> _requestPermissionsForIos() async {
    if (Platform.isIOS) {
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions();
    }
  }

  Future<void> onDidReceiveLocalNotification(int? id, String? title, String? body, String? payload) async {}

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    //print("initialMessage"+initialMessage.toString());
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    // handle background notification
    FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    //handle foreground notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("type1:${message.data['type'].toString()}");
      if (streamController != null && !streamController!.isClosed) {
        if(message.data['type'].toString() == 'place_order' || message.data['type'].toString() == 'order'){
          streamController!.sink.add("1");
        }
      }
      print("data:onMessage");
      print("data notification*********************************${message.data}");
      var data = message.data;
      print("data notification*********************************$data");
      var title = data['title'].toString();
      var body = data['body'].toString();
      var type = data['type'].toString();
      var image = data['image'].toString();
      var id = data['type_id'] ?? '';

      if (image != 'null' && image != '') {
        generateImageNotification(title, body, image, type, id);
      } else {
        generateSimpleNotification(title, body, type, id);
      }
    });
  }

  static Future<void> onBackgroundMessage(RemoteMessage remoteMessage) async {
    print("type2:${remoteMessage.data['type'].toString()}");
    //perform any background task if needed here
    if (streamController != null && !streamController!.isClosed) {
        if(remoteMessage.data['type'].toString() == 'place_order' || remoteMessage.data['type'].toString() == 'order'){
          streamController!.sink.add("1");
        }
    }
  }

// notification type is move to screen
  Future<void> _handleMessage(RemoteMessage message) async {
    print("type2:${message.data['type'].toString()}--${message.data['type'].toString() == 'place_order' || message.data['type'].toString() == 'order'}");
    if (streamController != null && !streamController!.isClosed) {
        if(message.data['type'].toString() == 'place_order' || message.data['type'].toString() == 'order'){
          streamController!.sink.add("1");
        }
    }
    if (message.data['type'] == 'category') {
      Navigator.of(context).pushNamed(Routes.cuisine, arguments: false);
    }
    if (message.data['type'] == "products") {
      //getProduct(id, 0, 0, true);
    } else if (message.data['type'] == "categories") {
      Navigator.of(context).pushNamed(Routes.cuisineDetail, arguments: {'categoryId': message.data['type_id'], 'name': UiUtils.getTranslatedLabel(context, deliciousCuisineLabel)});
    } else if (message.data['type'] == "wallet") {
      Navigator.of(context).pushNamed(Routes.wallet);
    } else if (message.data['type'] == 'place_order' || message.data['type'] == 'order') {
      Navigator.of(context).pushNamed(Routes.orderDetail, arguments: {
        'id': message.data['type_id'],
        'riderId': "",
        'riderName': "",
        'riderRating': "",
        'riderImage': "",
        'riderMobile': "",
        'riderNoOfRating': "",
        'isSelfPickup': "",
        'from': 'orderDetail'
      });
    } else if (message.data['type'] == "ticket_message") {
      Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => ChatScreen(
                  id: message.data['type_id'],
                  status: "",
                )),
      );
    } else if (message.data['type'] == "ticket_status") {
      Navigator.of(context).pushNamed(Routes.ticket);
    } else {
      Navigator.of(context).pushReplacementNamed(Routes.home/* , arguments: {'id': 0} */);
    }
  }

DarwinNotificationDetails darwinNotificationDetails =
    const DarwinNotificationDetails(
  categoryIdentifier: "",
);

  Future<void> generateImageNotification(String title, String msg, String image, String type, String? id) async {
    var largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
    var bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
    var bigPictureStyleInformation = BigPictureStyleInformation(FilePathAndroidBitmap(bigPicturePath),
        hideExpandedLargeIcon: true, contentTitle: title, htmlFormatContentTitle: true, summaryText: msg, htmlFormatSummaryText: true);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'com.wrteam.project1', //channel id
      'project1', //channel name
      channelDescription: 'project1', //channel description
      //playSound: true,
      //sound: const RawResourceAndroidNotificationSound('notification'),
      largeIcon: FilePathAndroidBitmap(largeIconPath),
      styleInformation: bigPictureStyleInformation, //icon: "@drawable/notification_icon",
    );
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: darwinNotificationDetails);
    await flutterLocalNotificationsPlugin.show(0, title, msg, platformChannelSpecifics, payload: "$type,${id!}");
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  // notification on foreground
  Future<void> generateSimpleNotification(String title, String msg, String type, String? id) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'com.wrteam.project1', //channel id
        'project1', //channel name
        channelDescription: 'project1', //channel description
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        //playSound: true,
        //sound: RawResourceAndroidNotificationSound('notification'),
        //icon: "@drawable/notification_icon"
        );
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: darwinNotificationDetails);
    await flutterLocalNotificationsPlugin.show(0, title, msg, platformChannelSpecifics, payload: "$type,${id!}");
  }
}