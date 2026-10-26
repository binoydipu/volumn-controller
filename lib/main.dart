import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VolumnControllerApp());
}

class VolumnControllerApp extends StatelessWidget {
  const VolumnControllerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volumn Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const SettingsScreen(),
    );
  }
}

class VolumeService {
  static const _channel = MethodChannel('com.volumncontroller/volume');

  static Future<bool> startNotificationService() async {
    try {
      return await _channel.invokeMethod<bool>('startNotificationService') ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to start service: ${e.message}');
      return false;
    }
  }

  static Future<bool> stopNotificationService() async {
    try {
      return await _channel.invokeMethod<bool>('stopNotificationService') ?? false;
    } on PlatformException catch (e) {
      debugPrint('Failed to stop service: ${e.message}');
      return false;
    }
  }

  static Future<bool> isNotificationServiceRunning() async {
    try {
      return await _channel.invokeMethod<bool>('isNotificationServiceRunning') ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> adjustVolume(String direction, String streamType) async {
    try {
      await _channel.invokeMethod('adjustVolume', {
        'direction': direction,
        'streamType': streamType,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to adjust volume: ${e.message}');
    }
  }

  static Future<void> showVolumePanel() async {
    try {
      await _channel.invokeMethod('showVolumePanel');
    } on PlatformException catch (e) {
      debugPrint('Failed to show volume panel: ${e.message}');
    }
  }

  static Future<Map<String, int>> getVolumeInfo(String streamType) async {
    try {
      final result = await _channel.invokeMethod<Map>('getVolumeInfo', {
        'streamType': streamType,
      });
      if (result != null) {
        return {
          'current': result['current'] as int? ?? 0,
          'min': result['min'] as int? ?? 0,
          'max': result['max'] as int? ?? 0,
        };
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to get volume info: ${e.message}');
    }
    return {'current': 0, 'min': 0, 'max': 0};
  }

  static Future<String> getVolumeStreamType() async {
    try {
      return await _channel.invokeMethod<String>('getVolumeStreamType') ?? 'media';
    } on PlatformException {
      return 'media';
    }
  }

  static Future<void> setVolumeStreamType(String streamType) async {
    try {
      await _channel.invokeMethod('setVolumeStreamType', {
        'streamType': streamType,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to set stream type: ${e.message}');
    }
  }

  static Future<bool> isNotificationEnabled() async {
    try {
      return await _channel.invokeMethod<bool>('isNotificationEnabled') ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> setNotificationEnabled(bool enabled) async {
    try {
      await _channel.invokeMethod('setNotificationEnabled', {
        'enabled': enabled,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to set notification enabled: ${e.message}');
    }
  }

  static Future<bool> hasNotificationPermission() async {
    try {
      return await _channel.invokeMethod<bool>('hasNotificationPermission') ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> requestNotificationPermission() async {
    try {
      return await _channel.invokeMethod<bool>('requestNotificationPermission') ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> openNotificationSettings() async {
    try {
      await _channel.invokeMethod('openNotificationSettings');
    } on PlatformException catch (e) {
      debugPrint('Failed to open settings: ${e.message}');
    }
  }

  static Future<void> openBatteryOptimizationSettings() async {
    try {
      await _channel.invokeMethod('openBatteryOptimizationSettings');
    } on PlatformException catch (e) {
      debugPrint('Failed to open battery settings: ${e.message}');
    }
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  bool _notificationEnabled = false;
  bool _hasNotificationPermission = false;
  bool _serviceRunning = false;
  String _selectedStreamType = 'media';
  Map<String, int> _volumeInfo = {'current': 0, 'min': 0, 'max': 0};
  bool _loading = true;

  static const _streamTypes = {
    'media': 'Media',
    'ringtone': 'Ringtone',
    'alarm': 'Alarm',
    'system': 'System',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshState();
    }
  }

  Future<void> _loadState() async {
    final results = await Future.wait([
      VolumeService.isNotificationEnabled(),
      VolumeService.hasNotificationPermission(),
      VolumeService.isNotificationServiceRunning(),
      VolumeService.getVolumeStreamType(),
    ]);

    final streamType = results[3] as String;
    final volumeInfo = await VolumeService.getVolumeInfo(streamType);

    if (mounted) {
      setState(() {
        _notificationEnabled = results[0] as bool;
        _hasNotificationPermission = results[1] as bool;
        _serviceRunning = results[2] as bool;
        _selectedStreamType = streamType;
        _volumeInfo = volumeInfo;
        _loading = false;
      });
    }
  }

  Future<void> _refreshState() async {
    final results = await Future.wait([
      VolumeService.hasNotificationPermission(),
      VolumeService.isNotificationServiceRunning(),
    ]);
    final volumeInfo = await VolumeService.getVolumeInfo(_selectedStreamType);

    if (mounted) {
      setState(() {
        _hasNotificationPermission = results[0] as bool;
        _serviceRunning = results[1] as bool;
        _volumeInfo = volumeInfo;
      });
    }
  }

  Future<void> _toggleNotification(bool enabled) async {
    if (enabled && !_hasNotificationPermission) {
      final granted = await VolumeService.requestNotificationPermission();
      if (!granted) {
        if (mounted) {
          _showPermissionDeniedDialog();
        }
        return;
      }
      setState(() => _hasNotificationPermission = true);
    }

    await VolumeService.setNotificationEnabled(enabled);
    setState(() => _notificationEnabled = enabled);

    // Brief delay to let service start/stop
    await Future.delayed(const Duration(milliseconds: 500));
    final running = await VolumeService.isNotificationServiceRunning();
    if (mounted) {
      setState(() => _serviceRunning = running);
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Permission Required'),
        content: const Text(
          'The notification permission is needed to show volume controls '
          'in the notification shade. You can enable it in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              VolumeService.openNotificationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _changeStreamType(String? streamType) async {
    if (streamType == null || streamType == _selectedStreamType) return;
    await VolumeService.setVolumeStreamType(streamType);
    final volumeInfo = await VolumeService.getVolumeInfo(streamType);
    if (mounted) {
      setState(() {
        _selectedStreamType = streamType;
        _volumeInfo = volumeInfo;
      });
    }

    // Restart service if running to pick up new stream type
    if (_serviceRunning) {
      await VolumeService.stopNotificationService();
      await VolumeService.startNotificationService();
    }
  }

  Future<void> _adjustVolume(String direction) async {
    await VolumeService.adjustVolume(direction, _selectedStreamType);
    // Short delay to let the system process the volume change
    await Future.delayed(const Duration(milliseconds: 100));
    final volumeInfo = await VolumeService.getVolumeInfo(_selectedStreamType);
    if (mounted) {
      setState(() => _volumeInfo = volumeInfo);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Volumn Controller'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildNotificationSection(),
          const SizedBox(height: 24),
          _buildVolumeTypeSection(),
          const SizedBox(height: 24),
          _buildVolumeTestSection(),
          const SizedBox(height: 24),
          _buildPermissionSection(),
          const SizedBox(height: 24),
          _buildInfoSection(),
        ],
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  color: _serviceRunning
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Persistent Notification',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                ),
                Switch(
                  value: _notificationEnabled,
                  onChanged: _toggleNotification,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _serviceRunning
                  ? 'Volume controls are active in your notification shade.'
                  : 'Enable to show volume controls in your notification shade.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            if (_notificationEnabled && !_serviceRunning) ...[
              const SizedBox(height: 8),
              Text(
                'Service is not running. It may have been stopped by the system.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeTypeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.tune),
                SizedBox(width: 12),
                Text(
                  'Volume Type',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...(_streamTypes.entries.map((entry) {
              return RadioListTile<String>(
                title: Text(entry.value),
                value: entry.key,
                groupValue: _selectedStreamType,
                onChanged: _changeStreamType,
                dense: true,
                contentPadding: EdgeInsets.zero,
              );
            })),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeTestSection() {
    final current = _volumeInfo['current'] ?? 0;
    final min = _volumeInfo['min'] ?? 0;
    final max = _volumeInfo['max'] ?? 1;
    final fraction = max > min ? (current - min) / (max - min) : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.volume_up),
                const SizedBox(width: 12),
                Text(
                  'Volume Test — ${_streamTypes[_selectedStreamType] ?? _selectedStreamType}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton.filled(
                  onPressed: () => _adjustVolume('down'),
                  icon: const Icon(Icons.remove),
                  tooltip: 'Volume Down',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: fraction,
                          minHeight: 12,
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$current / $max',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () => _adjustVolume('up'),
                  icon: const Icon(Icons.add),
                  tooltip: 'Volume Up',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: OutlinedButton.icon(
                onPressed: () => VolumeService.showVolumePanel(),
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open System Volume Panel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.security),
                SizedBox(width: 12),
                Text(
                  'Permissions & Settings',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                _hasNotificationPermission
                    ? Icons.check_circle
                    : Icons.cancel,
                color: _hasNotificationPermission
                    ? Colors.green
                    : Theme.of(context).colorScheme.error,
              ),
              title: const Text('Notification Permission'),
              subtitle: Text(
                _hasNotificationPermission
                    ? 'Granted'
                    : 'Required for persistent notification',
              ),
              trailing: !_hasNotificationPermission
                  ? TextButton(
                      onPressed: () async {
                        final granted =
                            await VolumeService.requestNotificationPermission();
                        if (!granted && mounted) {
                          VolumeService.openNotificationSettings();
                        }
                        _refreshState();
                      },
                      child: const Text('Grant'),
                    )
                  : null,
            ),
            const Divider(),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notification Settings'),
              subtitle: const Text('Open app notification settings'),
              onTap: () => VolumeService.openNotificationSettings(),
            ),
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.battery_saver),
              title: const Text('Battery Optimization'),
              subtitle: const Text(
                'Disable to prevent system from stopping the service',
              ),
              onTap: () => VolumeService.openBatteryOptimizationSettings(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline),
                SizedBox(width: 12),
                Text(
                  'About',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Volumn Controller provides quick access to volume controls '
              'through persistent notifications and home-screen widgets.\n\n'
              'Widgets: Add volume control widgets (1×1, 1×2, or 1×3) from '
              'your home screen\'s widget picker.\n\n'
              'Note: Android may stop background services to save battery. '
              'Disable battery optimization for this app to improve persistence. '
              'After a device reboot, the notification will be restored automatically '
              'if enabled.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
