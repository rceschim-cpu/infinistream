class StreamingAccountModel {
  final String providerName;
  final bool isConnected;
  final DateTime? lastUsed;
  final String? userEmail;
  final DateTime? snoozedUntil;

  const StreamingAccountModel({
    required this.providerName,
    required this.isConnected,
    this.lastUsed,
    this.userEmail,
    this.snoozedUntil,
  });

  bool get isInactive {
    if (!isConnected) return false;
    if (lastUsed == null) return false;
    return DateTime.now().difference(lastUsed!).inDays >= 30;
  }

  bool get shouldShowInactivityAlert {
    if (!isInactive) return false;
    if (snoozedUntil == null) return true;
    return DateTime.now().isAfter(snoozedUntil!);
  }

  int get daysSinceLastUse {
    if (lastUsed == null) return -1;
    return DateTime.now().difference(lastUsed!).inDays;
  }

  Map<String, dynamic> toJson() => {
        'providerName': providerName,
        'isConnected': isConnected,
        'lastUsed': lastUsed?.toIso8601String(),
        'userEmail': userEmail,
        'snoozedUntil': snoozedUntil?.toIso8601String(),
      };

  factory StreamingAccountModel.fromJson(Map<String, dynamic> json) {
    return StreamingAccountModel(
      providerName: json['providerName'] as String,
      isConnected: (json['isConnected'] as bool?) ?? false,
      lastUsed: json['lastUsed'] != null
          ? DateTime.parse(json['lastUsed'] as String)
          : null,
      userEmail: json['userEmail'] as String?,
      snoozedUntil: json['snoozedUntil'] != null
          ? DateTime.parse(json['snoozedUntil'] as String)
          : null,
    );
  }

  StreamingAccountModel copyWith({
    bool? isConnected,
    DateTime? lastUsed,
    String? userEmail,
    DateTime? snoozedUntil,
    bool clearSnoozedUntil = false,
  }) {
    return StreamingAccountModel(
      providerName: providerName,
      isConnected: isConnected ?? this.isConnected,
      lastUsed: lastUsed ?? this.lastUsed,
      userEmail: userEmail ?? this.userEmail,
      snoozedUntil:
          clearSnoozedUntil ? null : (snoozedUntil ?? this.snoozedUntil),
    );
  }
}
