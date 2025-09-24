enum PaymentNetwork {
  visa,
  masterCard,
  amex,
  discover,
  jcb,
  unionPay,
  maestro,
  girocard,
  interac,
  eftpos,
  other,
}

class PaymentPassRequest {
  final String cardholderName;
  final String primaryAccountSuffix;
  final String localizedDescription;
  final PaymentNetwork paymentNetwork;
  final Map<String, String> encryptedPassData;
  final String? activationData;
  final String? wrappingKeyHash;
  final Map<String, dynamic>? metadata;

  const PaymentPassRequest({
    required this.cardholderName,
    required this.primaryAccountSuffix,
    required this.localizedDescription,
    required this.paymentNetwork,
    required this.encryptedPassData,
    this.activationData,
    this.wrappingKeyHash,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'cardholderName': cardholderName,
      'primaryAccountSuffix': primaryAccountSuffix,
      'localizedDescription': localizedDescription,
      'paymentNetwork': paymentNetwork.name,
      'encryptedPassData': encryptedPassData,
      'activationData': activationData,
      'wrappingKeyHash': wrappingKeyHash,
      'metadata': metadata,
    };
  }

  factory PaymentPassRequest.fromJson(Map<String, dynamic> json) {
    return PaymentPassRequest(
      cardholderName: json['cardholderName'] as String,
      primaryAccountSuffix: json['primaryAccountSuffix'] as String,
      localizedDescription: json['localizedDescription'] as String,
      paymentNetwork: PaymentNetwork.values
          .firstWhere((e) => e.name == json['paymentNetwork']),
      encryptedPassData:
          Map<String, String>.from(json['encryptedPassData'] as Map),
      activationData: json['activationData'] as String?,
      wrappingKeyHash: json['wrappingKeyHash'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'PaymentPassRequest{cardholderName: $cardholderName, primaryAccountSuffix: $primaryAccountSuffix, localizedDescription: $localizedDescription, paymentNetwork: $paymentNetwork}';
  }
}