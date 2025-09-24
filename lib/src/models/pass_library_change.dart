enum PassLibraryChangeType {
  added,
  removed,
  replaced,
}

class PassLibraryChange {
  final PassLibraryChangeType type;
  final String passTypeIdentifier;
  final String serialNumber;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const PassLibraryChange({
    required this.type,
    required this.passTypeIdentifier,
    required this.serialNumber,
    required this.timestamp,
    this.metadata,
  });

  factory PassLibraryChange.fromJson(Map<String, dynamic> json) {
    return PassLibraryChange(
      type: PassLibraryChangeType.values
          .firstWhere((e) => e.name == json['type']),
      passTypeIdentifier: json['passTypeIdentifier'] as String,
      serialNumber: json['serialNumber'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'passTypeIdentifier': passTypeIdentifier,
      'serialNumber': serialNumber,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'PassLibraryChange{type: $type, passTypeIdentifier: $passTypeIdentifier, serialNumber: $serialNumber, timestamp: $timestamp}';
  }
}