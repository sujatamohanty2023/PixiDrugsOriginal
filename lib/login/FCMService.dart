import 'package:PixiDrugs/constant/all.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initFCMToken(BuildContext context) async {
    String? token = await _messaging.getToken();
    print('✅ FCM token $token');

    if (token != null) {
      updateTokenToServer(context, token);
      await saveFCMToken(token);
    }

    _messaging.onTokenRefresh.listen((newToken) async {
      updateTokenToServer(context, newToken);
      await saveFCMToken(newToken);
    });
  }

  static Future<void> saveFCMToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  static Future<String?> getFCMToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('fcm_token');
  }

  static Future<void> clearFCMToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('fcm_token');
  }

  Future<void> updateTokenToServer(BuildContext context, String token) async {
    String? user_id = await SessionManager.getUserId();

    if (user_id != null) {
      context.read<ApiCubit>().updateFCMtoken(user_id: user_id, fcm_token: token);
    }

    context.read<ApiCubit>().stream.listen((state) {
      if (state is UpdateFCMTokenLoaded) {
        print('✅ FCM token updated successfully');
      } else if (state is UpdateFCMTokenError) {
        print('❌ Failed to update FCM token: ${state.error}');
      }
    });
  }

  Future<void> initFCMMessage(BuildContext context) async {
    await _messaging.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await handleMessageNavigation(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      await handleMessageNavigation(message);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) async {
      if (message != null) {
        await handleMessageNavigation(message);
      }
    });
  }

  Future<void> handleMessageNavigation(RemoteMessage message) async {
    final data = message.data;
    final type = data['type'];
    final callId = data['receiver_id'];

    print('📥 FCM Received: ${data}');


  }
}
