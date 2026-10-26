import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:volumn_controller/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('com.volumncontroller/volume');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'isNotificationEnabled':
          return false;
        case 'hasNotificationPermission':
          return true;
        case 'isNotificationServiceRunning':
          return false;
        case 'getVolumeStreamType':
          return 'media';
        case 'getVolumeInfo':
          return {'current': 8, 'min': 0, 'max': 15};
        default:
          return true;
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  testWidgets('App renders SettingsScreen with volume controls', (WidgetTester tester) async {
    await tester.pumpWidget(const VolumnControllerApp());
    await tester.pumpAndSettle();

    expect(find.text('Volumn Controller'), findsWidgets);
    expect(find.text('Persistent Notification'), findsOneWidget);
    expect(find.text('Volume Type'), findsOneWidget);
    expect(find.text('Media'), findsOneWidget);
    expect(find.text('Ringtone'), findsOneWidget);
    expect(find.text('Alarm'), findsOneWidget);
    expect(find.text('System'), findsOneWidget);
    expect(find.text('Open System Volume Panel'), findsOneWidget);
  });
}
