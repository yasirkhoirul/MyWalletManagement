enum TypeTransaction {
  pemasukkan("Pemasukkan"),
  pengeluaran("Pengeluaran");

  final String typeText;
  const TypeTransaction(this.typeText);
}

/// Expense category for pengeluaran transactions
enum ExpenseCategory {
  makanan("Makanan"),
  transportasi("Transportasi"),
  belanja("Belanja"),
  hiburan("Hiburan"),
  kesehatan("Kesehatan"),
  pendidikan("Pendidikan"),
  tagihan("Tagihan"),
  lainnya("Lainnya");

  final String label;
  const ExpenseCategory(this.label);
}
