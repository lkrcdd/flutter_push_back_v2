import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'firebase_options.dart';

//fcm token
late String fcmToken;

//get fcm permission
Future<void> getFcmPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  debugPrint('[log] User granted fcm permission');
  debugPrint('[log] ${settings.authorizationStatus}');
}

@pragma('vm:entry-point')
Future<void> _setFcmListenerInBackground(RemoteMessage message) async {
  //얘가 지금 terminated상태까지 다 처리중!
  debugPrint("[log] got a message in background");

  // if (message.notification != null) {
  //   debugPrint('[log] Got a notification in message');
  //   final backNotiController = FlutterLocalNotificationsPlugin();
  //   var notiDetailForAnd = const AndroidNotificationDetails(
  //     'your channel id',
  //     'your channel name',
  //     channelDescription: 'your channel description',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     ticker: 'ticker',
  //   );
  //   var notiDetail = NotificationDetails(android: notiDetailForAnd);

  //   await backNotiController.show(
  //     1,
  //     message.notification!.title,
  //     message.notification!.body,
  //     notiDetail,
  //     payload: 'item x',
  //   );
  // }
}

//////////////////////main//////////////////////////////////////////////////////
Future<void> main() async {
  //init flutter engine
  WidgetsFlutterBinding.ensureInitialized();

  //fcm init
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  fcmToken = (await FirebaseMessaging.instance.getToken())!; //fcmtoken 받아오기.
  debugPrint('[log] fcm token : $fcmToken');
  FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
    debugPrint('[log] fcm token updated!!');
  }).onError((err) {
    debugPrint('[log] fcm token update error!!');
  });
  FirebaseMessaging.onBackgroundMessage(_setFcmListenerInBackground);

  //run
  runApp(const MaterialApp(home: TestApp()));
}

//App class
class TestApp extends StatefulWidget {
  const TestApp({super.key});

  @override
  State<TestApp> createState() => _TestAppState();
}

//App레벨에서 listener 등록해야 전체 앱에서 작동할듯?
class _TestAppState extends State<TestApp> {
  Future<void> _setFcmListenerInTerminated() async {
    //terminate 상태에서 알림 클릭 시 동작 지정
    //정상작동 확인
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    //background 상태에서 알림 클릭 시 동작 지정
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (BuildContext context) => SubPage(''),
    ));
  }

  @override
  void initState() {
    super.initState();
    _setFcmListenerInTerminated();
  }

  @override
  Widget build(BuildContext context) {
    return const MainPage();
  }
}

//main stf page
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        children: [
          const Spacer(),
          const Text('hi'),
          ElevatedButton(
            onPressed: () {},
            child: const Text('show'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('get notify permission'),
          ),
          ElevatedButton(
            onPressed: () async => getFcmPermission(),
            child: const Text('get fcm permission'),
          ),
          const Spacer(),
        ],
      )),
    );
  }
}

//sub stl page. when notification tapped
class SubPage extends StatelessWidget {
  var payload; //알람으로부터 넘겨받은 데이터

  SubPage(this.payload, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('back'),
        ),
      ),
    );
  }
}
