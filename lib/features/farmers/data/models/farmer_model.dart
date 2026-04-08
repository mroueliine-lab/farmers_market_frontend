class Farmer {
  final int id;
  final String firstname;
  final String lastname;
  final String email;
  final String phoneNumber;
  final String identifier;
  final double creditLimit;
  final List<Debt> debts;

  Farmer({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.phoneNumber,
    required this.identifier,
    required this.creditLimit,
    required this.debts,
  });

  String get fullName => '$firstname $lastname';

  String get initials {
    final f = firstname.isNotEmpty ? firstname[0] : '';
    final l = lastname.isNotEmpty ? lastname[0] : '';
    return (f + l).isNotEmpty ? (f + l) : '?';
  }

  double get totalDebt =>
      debts.fold(0, (sum, d) => sum + d.remainingBalance);

  double get availableCredit =>
      (creditLimit - totalDebt).clamp(0, creditLimit);

  factory Farmer.fromJson(Map<String, dynamic> json) {
    final debtsList = (json['debts'] as List? ?? [])
        .map((d) => Debt.fromJson(d))
        .toList();
    return Farmer(
      id: json['id'],
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
      identifier: json['identifier'],
      creditLimit: double.tryParse(json['credit_limit'].toString()) ?? 0.0,
      debts: debtsList,
    );
  }
}

class Debt {
  final int id;
  final double remainingBalance;

  Debt({required this.id, required this.remainingBalance});

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'],
      remainingBalance: double.tryParse(json['remaining_amount_fcfa'].toString()) ?? 0.0,
    );
  }
}
