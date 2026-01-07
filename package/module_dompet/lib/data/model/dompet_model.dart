/// Model class for Dompet (wallet) data
class DompetModel {
  final int id;
  final String userId;
  final double amount;
  final double pengeluaran;
  final double pemasukkan;

  const DompetModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.pengeluaran,
    required this.pemasukkan,
  });

  /// Calculate balance (amount + pemasukkan - pengeluaran)
  double get balance => amount + pemasukkan - pengeluaran;
}
