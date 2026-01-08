// services/system_notification_service.dart
import 'dart:async';

class SystemNotificationService {
  static final SystemNotificationService _instance = SystemNotificationService._internal();
  factory SystemNotificationService() => _instance;
  SystemNotificationService._internal();

  bool _isNotificationActive = false;
  Timer? _notificationTimer;
  Duration _currentDuration = Duration.zero;

  final _notificationStreamController = StreamController<Map<String, dynamic>>();
  Stream<Map<String, dynamic>> get notificationStream => _notificationStreamController.stream;

  Future<void> initialize() async {
    print('🔔 System Notification Service Initialized');
  }

  void startTimerNotification() {
    if (_isNotificationActive) return;

    _isNotificationActive = true;
    _currentDuration = Duration.zero;

    print('🔔 SYSTEM NOTIFICATION STARTED');
    
    _notificationStreamController.add({
      'isActive': true,
      'type': 'timer_started',
      'duration': _currentDuration,
    });

    _notificationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentDuration += const Duration(seconds: 1);
      
      if (_currentDuration.inSeconds % 10 == 0) {
        print('🔔 SIPAKARENA - Memasak... Waktu: ${_formatDuration(_currentDuration)}');
      }

      _notificationStreamController.add({
        'isActive': true,
        'type': 'timer_updated',
        'duration': _currentDuration,
      });
    });
  }

  void stopTimerNotification() {
    _isNotificationActive = false;
    _notificationTimer?.cancel();
    _notificationTimer = null;

    print('🔔 SYSTEM NOTIFICATION STOPPED - Total waktu: ${_formatDuration(_currentDuration)}');
    print('🔔 SIPAKARENA - SELESAI! Total waktu: ${_formatDuration(_currentDuration)}');

    _notificationStreamController.add({
      'isActive': false,
      'type': 'timer_finished',
      'duration': _currentDuration,
    });

    _currentDuration = Duration.zero;
  }

  void cancelTimerNotification() {
    _isNotificationActive = false;
    _notificationTimer?.cancel();
    _notificationTimer = null;
    _currentDuration = Duration.zero;

    print('🔔 SYSTEM NOTIFICATION CANCELLED');
    
    _notificationStreamController.add({
      'isActive': false,
      'type': 'timer_cancelled',
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  bool get isNotificationActive => _isNotificationActive;
  Duration get currentDuration => _currentDuration;

  void dispose() {
    _notificationTimer?.cancel();
    _notificationStreamController.close();
  }
}


