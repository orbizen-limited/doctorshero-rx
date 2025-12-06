class SessionModel {
  final int id;
  final String device;
  final String lastUsed;
  final String createdAt;
  final bool isCurrent;

  SessionModel({
    required this.id,
    required this.device,
    required this.lastUsed,
    required this.createdAt,
    required this.isCurrent,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as int,
      device: json['device'] as String,
      lastUsed: json['last_used'] as String,
      createdAt: json['created_at'] as String,
      isCurrent: json['is_current'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device': device,
      'last_used': lastUsed,
      'created_at': createdAt,
      'is_current': isCurrent,
    };
  }

  // Get formatted last used time
  String get formattedLastUsed {
    try {
      final dateTime = DateTime.parse(lastUsed);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return '${difference.inDays}d ago';
      }
    } catch (e) {
      return lastUsed;
    }
  }

  // Get device type icon
  String get deviceIcon {
    final deviceLower = device.toLowerCase();
    if (deviceLower.contains('mobile') || deviceLower.contains('iphone') || deviceLower.contains('android')) {
      return '📱';
    } else if (deviceLower.contains('tablet') || deviceLower.contains('ipad')) {
      return '📲';
    } else {
      return '💻';
    }
  }
}
