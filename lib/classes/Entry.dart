class Entry {
  late final String? documentId;
  final String name;
  final String category;
  final double amount;
  final DateTime date;

  Entry({
    this.documentId,
    required this.name,
    required this.category,
    required this.amount,
    required this.date,
  });
}
