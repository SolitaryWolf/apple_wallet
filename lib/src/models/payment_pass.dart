class PaymentPass {
  final String passTypeIdentifier;
  final String serialNumber;
  final String localizedDescription;
  final String organizationName;
  final bool isActivated;
  final DateTime? activationDate;
  final Map<String, dynamic>? metadata;

  const PaymentPass({
    required this.passTypeIdentifier,
    required this.serialNumber,
    required this.localizedDescription,
    required this.organizationName,
    required this.isActivated,
    this.activationDate,
    this.metadata,
  });

  factory PaymentPass.fromJson(Map<String, dynamic> json) {
    return PaymentPass(
      passTypeIdentifier: json['passTypeIdentifier'] as String,
      serialNumber: json['serialNumber'] as String,
      localizedDescription: json['localizedDescription'] as String,
      organizationName: json['organizationName'] as String,
      isActivated: json['isActivated'] as bool,
      activationDate: json['activationDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['activationDate'] as int)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'passTypeIdentifier': passTypeIdentifier,
      'serialNumber': serialNumber,
      'localizedDescription': localizedDescription,
      'organizationName': organizationName,
      'isActivated': isActivated,
      'activationDate': activationDate?.millisecondsSinceEpoch,
      'metadata': metadata,
    };
  }

  @override
  String toString() {
    return 'PaymentPass{passTypeIdentifier: $passTypeIdentifier, serialNumber: $serialNumber, localizedDescription: $localizedDescription, organizationName: $organizationName, isActivated: $isActivated}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentPass &&
          runtimeType == other.runtimeType &&
          passTypeIdentifier == other.passTypeIdentifier &&
          serialNumber == other.serialNumber;

  @override
  int get hashCode => passTypeIdentifier.hashCode ^ serialNumber.hashCode;
}