/// Data models for Simple Queue API

class Queue {
  final String id;
  final String name;
  final String description;
  final String code;
  final QueueStatus status;
  final int currentPosition;
  final int totalInQueue;
  final double averageWaitTime;
  final DateTime? opensAt;
  final DateTime? closesAt;
  final Location? location;
  final Map<String, dynamic>? metadata;

  Queue({
    required this.id,
    required this.name,
    required this.description,
    required this.code,
    required this.status,
    required this.currentPosition,
    required this.totalInQueue,
    required this.averageWaitTime,
    this.opensAt,
    this.closesAt,
    this.location,
    this.metadata,
  });

  factory Queue.fromJson(Map<String, dynamic> json) {
    return Queue(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      code: json['code'],
      status: QueueStatus.fromString(json['status']),
      currentPosition: json['currentPosition'] ?? 0,
      totalInQueue: json['totalInQueue'] ?? 0,
      averageWaitTime: (json['averageWaitTime'] ?? 0).toDouble(),
      opensAt: json['opensAt'] != null ? DateTime.parse(json['opensAt']) : null,
      closesAt: json['closesAt'] != null ? DateTime.parse(json['closesAt']) : null,
      location: json['location'] != null ? Location.fromJson(json['location']) : null,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'code': code,
      'status': status.name,
      'currentPosition': currentPosition,
      'totalInQueue': totalInQueue,
      'averageWaitTime': averageWaitTime,
      'opensAt': opensAt?.toIso8601String(),
      'closesAt': closesAt?.toIso8601String(),
      'location': location?.toJson(),
      'metadata': metadata,
    };
  }

  /// Formater ventetid som lesbar streng
  String get formattedWaitTime {
    if (averageWaitTime < 1) {
      return '${(averageWaitTime * 60).round()} min';
    }
    return '${averageWaitTime.round()} t';
  }

  /// Sjekk om køen er åpen nå
  bool get isOpenNow {
    if (status != QueueStatus.active) return false;
    if (opensAt == null || closesAt == null) return true;
    
    final now = DateTime.now();
    return now.isAfter(opensAt!) && now.isBefore(closesAt!);
  }
}

enum QueueStatus {
  active,
  paused,
  closed;

  factory QueueStatus.fromString(String value) {
    return QueueStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => QueueStatus.closed,
    );
  }
}

class Ticket {
  final String id;
  final String queueId;
  final String queueName;
  final String number;
  final int position;
  final TicketStatus status;
  final DateTime createdAt;
  final DateTime? calledAt;
  final DateTime? completedAt;
  final int estimatedWaitMinutes;
  final Map<String, dynamic>? metadata;

  Ticket({
    required this.id,
    required this.queueId,
    required this.queueName,
    required this.number,
    required this.position,
    required this.status,
    required this.createdAt,
    this.calledAt,
    this.completedAt,
    required this.estimatedWaitMinutes,
    this.metadata,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id'],
      queueId: json['queueId'],
      queueName: json['queueName'] ?? '',
      number: json['number'],
      position: json['position'] ?? 0,
      status: TicketStatus.fromString(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      calledAt: json['calledAt'] != null ? DateTime.parse(json['calledAt']) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt']) : null,
      estimatedWaitMinutes: json['estimatedWaitMinutes'] ?? 0,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'queueId': queueId,
      'queueName': queueName,
      'number': number,
      'position': position,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'calledAt': calledAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'estimatedWaitMinutes': estimatedWaitMinutes,
      'metadata': metadata,
    };
  }

  /// Formater estimert ventetid
  String get formattedEstimatedWait {
    if (estimatedWaitMinutes < 60) {
      return '$estimatedWaitMinutes min';
    }
    final hours = estimatedWaitMinutes ~/ 60;
    final mins = estimatedWaitMinutes % 60;
    if (mins == 0) return '$hours t';
    return '$hours t $mins min';
  }

  /// Beregn faktisk ventetid (hvis fullført)
  Duration? get actualWaitTime {
    if (calledAt == null) return null;
    return calledAt!.difference(createdAt);
  }

  /// Er billetten aktiv
  bool get isActive => status == TicketStatus.waiting || status == TicketStatus.called;
}

enum TicketStatus {
  waiting,
  called,
  completed,
  cancelled,
  noShow;

  factory TicketStatus.fromString(String value) {
    return TicketStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TicketStatus.waiting,
    );
  }

  String get displayName {
    switch (this) {
      case TicketStatus.waiting:
        return 'Venter';
      case TicketStatus.called:
        return 'Din tur!';
      case TicketStatus.completed:
        return 'Fullført';
      case TicketStatus.cancelled:
        return 'Kansellert';
      case TicketStatus.noShow:
        return 'Møtte ikke opp';
    }
  }

  Color get color {
    switch (this) {
      case TicketStatus.waiting:
        return const Color(0xFF6366F1);
      case TicketStatus.called:
        return const Color(0xFF22C55E);
      case TicketStatus.completed:
        return const Color(0xFF6B7280);
      case TicketStatus.cancelled:
        return const Color(0xFFEF4444);
      case TicketStatus.noShow:
        return const Color(0xFFF59E0B);
    }
  }
}

class Location {
  final String? address;
  final double? latitude;
  final double? longitude;

  Location({
    this.address,
    this.latitude,
    this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      address: json['address'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class QueueStats {
  final String queueId;
  final int totalTickets;
  final int completedTickets;
  final int cancelledTickets;
  final double averageWaitTime;
  final double averageServiceTime;
  final DateTime periodStart;
  final DateTime periodEnd;

  QueueStats({
    required this.queueId,
    required this.totalTickets,
    required this.completedTickets,
    required this.cancelledTickets,
    required this.averageWaitTime,
    required this.averageServiceTime,
    required this.periodStart,
    required this.periodEnd,
  });

  factory QueueStats.fromJson(Map<String, dynamic> json) {
    return QueueStats(
      queueId: json['queueId'],
      totalTickets: json['totalTickets'] ?? 0,
      completedTickets: json['completedTickets'] ?? 0,
      cancelledTickets: json['cancelledTickets'] ?? 0,
      averageWaitTime: (json['averageWaitTime'] ?? 0).toDouble(),
      averageServiceTime: (json['averageServiceTime'] ?? 0).toDouble(),
      periodStart: DateTime.parse(json['periodStart']),
      periodEnd: DateTime.parse(json['periodEnd']),
    );
  }
}
