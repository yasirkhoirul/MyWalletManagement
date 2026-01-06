class DompetMonthEntity {
  final int? id;
  final double pemasukkan;
  final double pengeluaran;
  final int month;
  final int year;
  final int dompetid;

  DompetMonthEntity({
    this.id,
    required this.pemasukkan,
    required this.pengeluaran,
    required this.month,
    required this.year,
    required this.dompetid,
  });
}
