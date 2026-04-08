class DebtModel {
  final int id;
  final double originalAmountFcfa;
  final double remainingAmountFcfa;
  final String status;
  final int transactionId;

  DebtModel({
    required this.id,
    required this.originalAmountFcfa,
    required this.remainingAmountFcfa,
    required this.status,
    required this.transactionId,
  });

  factory DebtModel.fromJson(Map<String, dynamic> json) {
    return DebtModel(
      id: json['id'],
      originalAmountFcfa: double.tryParse(json['original_amount_fcfa'].toString()) ?? 0.0,
      remainingAmountFcfa: double.tryParse(json['remaining_amount_fcfa'].toString()) ?? 0.0,
      status: json['status'],
      transactionId: json['transaction_id'],
    );
  }
}
