/// Entity class for Dompet (wallet) domain layer
class DompetEntity {
  final int id;
  final String userId;
  final double amount;
  final double pengeluaran;
  final double pemasukkan;

  const DompetEntity({
    required this.id,
    required this.userId,
    required this.amount,
    required this.pengeluaran,
    required this.pemasukkan,
  });

  /// Calculate balance (initial amount + income - expense)
  double get balance => amount + pemasukkan - pengeluaran;
}
