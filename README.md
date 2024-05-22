# flutter_push_back_v2

## 사용할 패키지
local_notification : 푸쉬 알림 표시 패키지
https://pub.dev/packages/flutter_local_notifications
isolate : 백그라운드 프로세스 구동 패키지
https://dart-ko.dev/language/concurrency
firebase_messageing : 푸쉬 알림
https://pub.dev/packages/firebase_messaging
https://firebase.google.com/docs/cloud-messaging/flutter/client?hl=ko#platform-specific_setup_and_requirements

## 참고 링크
firebase console page
https://console.firebase.google.com/project/_/messaging?_gl=1*1io773g*_up*MQ..*_ga*Njk0MjQyOTE4LjE3MTU5NjI2Mjg.*_ga_CW55HF8NVT*MTcxNTk2MjYyNy4xLjAuMTcxNTk2MjYyNy4wLjAuMA..

send fcm data message
https://stackoverflow.com/questions/40726030/unable-to-send-data-message-using-firebase-console

## base
- application state
앱의 3가지 상태 : Foregroud / Backgroud / Terminate

- pragma('vm:entry-point') annotation
앱이 백그라운드에 진입 시, OS는 dart code를 다시 실행시키고, 이 때 해당 entry point로 이동.

- listener와 stream
stream : events의 흐름 수신
linstener : 특정 event 수신

- about notification
Push Notification (푸시 알림):
푸시 알림은 서버에서 클라이언트 앱으로 전송되는 메시지입니다. 사용자가 앱을 사용하지 않는 상태에서도 알림을 받을 수 있습니다. 이것은 Firebase Cloud Messaging(FCM), OneSignal, 또는 해당 플랫폼의 기타 푸시 알림 서비스를 통해 전송됩니다.
Local Notification (로컬 알림):
로컬 알림은 사용자의 디바이스에서 앱 자체에서 생성되고 예약된 알림입니다. 푸시 알림과 달리, 로컬 알림은 앱이 사용자의 디바이스에 직접 예약합니다. 따라서 네트워크 연결 없이도 작동합니다. 특정 시간, 날짜 또는 사용자의 특정 동작에 응답하여 표시될 수 있습니다.
In-App Notification (인앱 알림):
인앱 알림은 사용자가 앱 내부에서 볼 수 있는 알림입니다. 이것은 주로 앱의 일부로 포함되어 있으며, 일반적으로 사용자에게 메시지를 전달하거나 액션을 유도하기 위해 사용됩니다. 푸시 알림과 달리, 인앱 알림은 사용자가 앱을 열어야만 볼 수 있습니다.
Terminated Notification (종료된 알림):
앱이 종료된 상태에서 사용자에게 알림을 표시하는 것을 말합니다. 이러한 종류의 알림은 보통 푸시 알림 또는 로컬 알림을 통해 구현됩니다. 사용자가 앱을 완전히 종료한 경우에도 알림을 받을 수 있습니다.
알림 수신을 대기하는 백그라운드 프로세스의 종료 지점은 일반적으로 사용자가 해당 서비스를 명시적으로 중지하거나 시스템 리소스가 부족하여 시스템이 해당 프로세스를 종료시킬 때입니다. 또한, 특정 작업이 완료되었거나 특정 조건이 충족되었을 때 백그라운드 프로세스가 자체적으로 종료될 수도 있습니다.

#### local notification
onDidReceiveNotificationResponse
-> 알림을 탭하였을 때의 handler 지정
onDidReceiveBackgroundNotificationResponse
-> app이 background 상태일 때 알림을 받았을 경우, 알림을 탭하는 행동을 제외한 모든 행동에 대한 handler 지정
@pragma annotation 필수

notification Id : 각 알람의 인스턴스 식별
notification Channel Id : 같은 유형의 알림, 또는 순서대로 알림이 떠야 할 때 같은 채널에 등록.
notification Stream : 알림에 대한 이벤트 핸들링

#### FCM
- FCM token
firebase cloud에서 메시지를 보낼 유저를 특정하기 위한 token.
만료 기간 없음.
    -> 삭제 조건
    1. 사용자가 앱 데이터 삭제
    2. 사용자가 앱 제거/재설치
    3. 새 기기에서 앱 설치

- FCM Auto Initialization
-> 앱 첫 시작시에만 실행됨. getTocken해도 기존 토큰이 있다면 그걸 받아온다는 뜻.

- FCM message test control
console page 
-> (프로젝트 없다면 프로젝트 생성)프로젝트 진입 -> 메시지 탭
-> 캠페인 없다면 생성. 앱 외부 메시지 선택
-> 대충적고 테스트메시지 전송 클릭.
-> fcm토큰 등록 or 있는거 선택 후 테스트
이는 알림 메시지만 송신 가능

- cm tocken 추적 등록
FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
    // TODO: If necessary send token to application server.
    // Note: This callback is fired at each app startup and whenever a new
    // token is generated.
  }).onError((err) {
    // Error getting token.
  });

- FCM permission
The authorizationStatus property of the NotificationSettings object returned from the request can be used to determine the user's overall decision:
    authorized: The user granted permission.
    denied: The user denied permission.
    notDetermined: The user has not yet chosen whether to grant permission.
    provisional: The user granted provisional permission
The other properties on NotificationSettings return whether a specific permission is enabled, disabled or not supported on the current device.
Once permission has been granted and the different types of device state have been understood, your application can now start to handle the incoming FCM payloads.

- foreground에서의 메시지 처리
FirebaseMessaging.onMessage.listen((RemoteMessage message){~})

- background & terminated 상태에서의 메시지 처리
FirebaseMessaging.onBackgroundMessage(handler);
handler(RemoteMessage msg){~}

- 메시지에 대한 상호작용 처리
notification의 handler와는 별도로 동작
getInitialMessage(): terminated 상태에서 앱이 열릴 때
onMessageOpenedApp: background 상태에서 앱이 열릴 때

- fcm RemoteMessage obj
메시지 ID: messageId 속성을 사용하여 메시지의 고유 식별자를 얻을 수 있습니다.
메시지 데이터: data 속성을 통해 메시지에 포함된 사용자 정의 데이터를 얻을 수 있습니다.
알림 정보: notification 속성을 통해 알림에 관련된 정보를 얻을 수 있습니다. 이 정보에는 제목(title), 본문(body), 이미지(image) 등이 포함될 수 있습니다.
메시지 타입: messageType 속성을 통해 메시지의 유형을 확인할 수 있습니다. 일반적으로 data 또는 notification 속성 중 하나가 포함되어 있습니다.
배달 시간: sentTime 속성을 사용하여 메시지를 보낸 시간을 확인할 수 있습니다.
메시지 토큰: token 속성을 통해 메시지를 수신한 기기의 토큰을 확인할 수 있습니다.

## Setting
#### local_notification setting
1. android/app/build.gradle에 종속성 추가
android {
    ...
    compileSdk flutter.compileSdkVersion  //doctor로 확인해서 34이하면 34로 명시
    ...
    compileOptions {
        coreLibraryDesugaringEnabled true
        ...
    }
    defaultConfig {
        ...
        multiDexEnabled true
    }
    ...
}
dependencies {
    implementation 'androidx.window:window:1.0.0'
    implementation 'androidx.window:window-java:1.0.0'
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:1.2.2'
}

2. android/build.gradle에 종속성 추가
코드 최상단에 추가
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.1'
    }
}

3. android/app/src/main/AndroidManifest.xml 세팅
application 태그 내의 하단에 추가
<receiver 
  android:exported="false" 
  android:name="com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver" />

4. permission 받기
notiController
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestNotificationsPermission();
그럼 notify 시 권한이 있는지 확인하는 함수도 필요할듯.


#### flutter_background_service setting 
1. android/build.gradle setting
buildscript {
    ext.kotlin_version = '1.8.10' <-
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.4.2' <-
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version" <-
    }
}

2. android/app/build.gradle setting
dependencies에 추가
implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk8:$kotlin_version"

3. android/gradle/wrapper/gradle-wrapper.properties
-> distributionUrl=https\://services.gradle.org/distributions/gradle-7.5-all.zip 로 변경

4. permission setting
android/app/src/main/AndroidManifest.xml에 permission 코드 추가
<manifest xmlns:android="http://schemas.android.com/apk/res/android" xmlns:tools="http://schemas.android.com/tools" package="com.example">
  ...
  <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
...

#### firebase_messaging setting
1. firebase setting
install firebase cli
firebase login
firebase configure

## 발생한 오류
1. E/AndroidRuntime(10621): java.lang.NoSuchMethodError: No interface method addWindowLayoutInfoListener(Landroid/app/Activity;Lj$/util/function/Consumer;)V in class Landroidx/window/extensions/layout/WindowLayoutComponent; or its super classes (declaration of 'androidx.window.extensions.layout.WindowLayoutComponent' appears in /system_ext/framework/androidx.window.extensions.jar)
-> 안드로이드 디슈가 문제. android/app/build.gradle에 다음 implementation 추가
dependencies {
    implementation 'androidx.window:window:1.0.0'
    implementation 'androidx.window:window-java:1.0.0'
    coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:1.2.2'
}

2. backservice 패키지 추가 과정 중 발생한 오류
flutter_backservice & local_notification 같이 쓸 때 충돌남.
flutter_background_service setting 2번 implementation으로 해결
> 오류내역
    FAILURE: Build failed with an exception.
    * What went wrong:
    Execution failed for task ':app:checkDebugDuplicateClasses'.
    > A failure occurred while executing com.android.build.gradle.internal.tasks.CheckDuplicatesRunnable
    > Duplicate class kotlin.collections.jdk8.CollectionsJDK8Kt found in modules jetified-kotlin-stdlib-1.8.22 (org.jetbrains.kotlin:kotlin-stdlib:1.8.22) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)
        Duplicate class kotlin.internal.jdk7.JDK7PlatformImplementations found in modules jetified-kotlin-stdlib-1.8.22 (org.jetbrains.kotlin:kotlin-stdlib:1.8.22) and jetified-kotlin-stdlib-jdk7-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.7.10)
        Duplicate class kotlin.internal.jdk7.JDK7PlatformImplementations$ReflectSdkVersion found in modules jetified-kotlin-stdlib-1.8.22 (org.jetbrains.kotlin:kotlin-stdlib:1.8.22) and jetified-kotlin-stdlib-jdk7-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.7.10)
        Duplicate class kotlin.internal.jdk8.JDK8PlatformImplementations found in modules jetified-kotlin-stdlib-1.8.22 (org.jetbrains.kotlin:kotlin-stdlib:1.8.22) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)
        Duplicate class kotlin.internal.jdk8.JDK8PlatformImplementations$ReflectSdkVersion found in modules jetified-kotlin-stdlib-1.8.22 (org.jetbrains.kotlin:kotlin-stdlib:1.8.22) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)
        Duplicate class kotlin.io.path.ExperimentalPathApi found in modules jetified-kotlin-stdlib-1.8.22 (org.jetbrains.kotlin:kotlin-stdlib:1.8.22) and jetified-kotlin-stdlib-jdk7-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.7.10)
        Duplicate class kotlin.io.path.PathRelativizer found in modules jetified-kotlin-stdlib-1.8.22 (org.jetbrains.kotlin:kotlin-stdlib:1.8.22) and jetified-kotlin-stdlib-jdk7-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.7.10)
        Duplicate class kotlin.io.path.PathsKt found in modules jetified-kotlin-stdlib-1.8.22 (org.jetbrains.kotlin:kotlin-stdlib:1.8.22) and jetified-kotlin-stdlib-jdk7-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.7.10)
        Duplicate class kotlin.io.path.PathsKt__PathReadWriteKt found in modules jetified-kotlin-stdlib-1.8.22 (org.jetbrains.kotlin:kotlin-stdlib:1.8.22) and jetified-kotlin-stdlib-jdk7-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.7.10)
        Duplicate class kotlin.io.path.PathsKt__PathUtilsKt found in modules jetified-kotlin-stdlib-1.8.22 (org.jetbrains.kotlin:kotlin-stdlib:1.8.22) and jetified-kotlin-stdlib-jdk7-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.7.10)
        Duplicate class kotlin.jdk7.AutoCloseableKt found in modules jetified-kotlin-stdlib-1.8.22 (org.jetbrains.kotlin:kotlin-stdlib:1.8.22) and jetified-kotlin-stdlib-jdk7-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.7.10)
        Duplicate class kotlin.jvm.jdk8.JvmRepeatableKt found in modules jetified-kotlin-stdlib-1.8.22 (org.jetbrains.kotlin:kotlin-stdlib:1.8.22) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)
        Duplicate class kotlin.jvm.optionals.OptionalsKt found in modules jetified-kotlin-stdlib-1.8.22 (org.jetbrains.kotlin:kotlin-stdlib:1.8.22) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)
        Duplicate class kotlin.random.jdk8.PlatformThreadLocalRandom found in modules jetified-kotlin-stdlib-1.8.22 (org.jetbrains.kotlin:kotlin-stdlib:1.8.22) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)
        Duplicate class kotlin.streams.jdk8.StreamsKt found in modules jetified-kotlin-stdlib-1.8.22 (org.jetbrains.kotlin:kotlin-stdlib:1.8.22) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)
        Duplicate class kotlin.streams.jdk8.StreamsKt$asSequence$$inlined$Sequence$1 found in modules jetified-kotlin-stdlib-1.8.22 (org.jetbrains.kotlin:kotlin-stdlib:1.8.22) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)
        Duplicate class kotlin.streams.jdk8.StreamsKt$asSequence$$inlined$Sequence$2 found in modules jetified-kotlin-stdlib-1.8.22 (org.jetbrains.kotlin:kotlin-stdlib:1.8.22) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)
        Duplicate class kotlin.streams.jdk8.StreamsKt$asSequence$$inlined$Sequence$3 found in modules jetified-kotlin-stdlib-1.8.22 (org.jetbrains.kotlin:kotlin-stdlib:1.8.22) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)
        Duplicate class kotlin.streams.jdk8.StreamsKt$asSequence$$inlined$Sequence$4 found in modules jetified-kotlin-stdlib-1.8.22 (org.jetbrains.kotlin:kotlin-stdlib:1.8.22) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)
        Duplicate class kotlin.text.jdk8.RegexExtensionsJDK8Kt found in modules jetified-kotlin-stdlib-1.8.22 (org.jetbrains.kotlin:kotlin-stdlib:1.8.22) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)
        Duplicate class kotlin.time.jdk8.DurationConversionsJDK8Kt found in modules jetified-kotlin-stdlib-1.8.22 (org.jetbrains.kotlin:kotlin-stdlib:1.8.22) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)
        Go to the documentation to learn how to <a href="d.android.com/r/tools/classpath-sync-errors">Fix dependency resolution errors</a>.
    * Try:
    > Run with --stacktrace option to get the stack trace.
    > Run with --info or --debug option to get more log output.
    > Run with --scan to get full insights.
    * Get more help at https://help.gradle.org
    BUILD FAILED in 10s
    Error: Gradle task assembleDebug failed with exit code 1
    Exited (1).

3. context가 materialApp이랑 같은 레벨에 있을 때 동작 안함.
-> runApp(materialApp(home:MainApp))처럼 상위에 위치시킨다.

4. D/CompatibilityChangeReporter(11143): Compat change id reported: 160794467; UID 10198; state: ENABLED
W/WindowOnBackDispatcher(11143): OnBackInvokedCallback is not enabled for the application.
W/WindowOnBackDispatcher(11143): Set 'android:enableOnBackInvokedCallback="true"' in the application manifest.
-> 다음 코드 추가
<application
        ...
        android:enableOnBackInvokedCallback="true">
...
</application>

5. firebase configure 중 packagename 오류
packagename이 너무 길면 cli에서 안됨.
android/app/google-services.json에서 직접 packagename 입력

6. fcm과 local notification이 겹쳐서 2번 알림이 출력되는 문제
https://stackoverflow.com/questions/76718155/flutter-fcm-notification-appears-twice-when-app-is-in-background
-> fcm에서 보내는 메시지를 '알림 메시지'가 아닌 '데이터 메시지'로 보내야 함.

### rlxk
notificationChannelId == foregroundServiceType in manifest

용법 :
작업을 처리할 최상위 또는 정적 메서드를 구성해야 합니다 .
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // handle action
}
initialize이 플러그인의 메소드 에서 이 함수를 매개변수로 지정하십시오 .

await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        // ...
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
);
이 기능은 별도의 격리에서 실행된다는 점을 기억하세요(Linux 제외)! 또한 이 함수에는 @pragma('vm:entry-point')네이티브 측에서 호출되므로 트리 쉐이킹으로 인해 코드가 제거되지 않도록 하기 위한 주석이 필요합니다. 주석에 대한 공식 문서는 여기를 참조하세요 .

또한 개발자는 플러그인에 액세스하는 동안 작동하지만 Android에서는 컨텍스트 에 액세스 할 수 없다는Activity 점에 유의해야 합니다 . 이는 일부 플러그인(예 url_launcher: )이 메인을 Activity다시 시작하려면 추가 플래그가 필요하다는 것을 의미합니다.

알림에 대한 작업 지정 :

알림 작업은 플랫폼마다 다르며 플랫폼마다 다르게 지정해야 합니다.

iOS/macOS에서 작업은 카테고리에 정의됩니다. 자세한 내용은 구성 섹션을 참조하세요.

Android 및 Linux에서는 작업이 알림에서 직접 구성됩니다.

Future<void> _showNotificationWithActions() async {
  const AndroidNotificationDetails androidNotificationDetails =
      AndroidNotificationDetails(
    '...',
    '...',
    '...',
    actions: <AndroidNotificationAction>[
      AndroidNotificationAction('id_1', 'Action 1'),
      AndroidNotificationAction('id_2', 'Action 2'),
      AndroidNotificationAction('id_3', 'Action 3'),
    ],
  );
  const NotificationDetails notificationDetails =
      NotificationDetails(android: androidNotificationDetails);
  await flutterLocalNotificationsPlugin.show(
      0, '...', '...', notificationDetails);
}
각 알림에는 내부 ID와 공개 작업 제목이 있습니다.

