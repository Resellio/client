class CheckoutDto {
  const CheckoutDto({
    required this.amount,
    required this.currency,
    required this.cardNumber,
    required this.cardExpiry,
    required this.cvv,
  });

  final double amount;
  final String currency;
  final String cardNumber;
  final String cardExpiry;
  final String cvv;

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency': currency,
        'cardNumber': cardNumber,
        'cardExpiry': cardExpiry,
        'cvv': cvv,
      };
}

class PaymentResponse {
  const PaymentResponse({
    required this.transactionId,
    required this.status,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      transactionId: json['transaction_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
    );
  }

  final String transactionId;
  final String status;

  bool get isSuccess => status.toLowerCase() == 'success';
}
