import 'dart:io';
import 'package:flutter/material.dart';
import 'package:module_core/constant/constant.dart';
import 'package:module_dompet/domain/entities/transaction_entity.dart';

class TransactionDetailDialog extends StatefulWidget {
  final TransactionEntity transaction;
  const TransactionDetailDialog({super.key, required this.transaction});

  @override
  State<TransactionDetailDialog> createState() =>
      _TransactionDetailDialogState();
}

class _TransactionDetailDialogState extends State<TransactionDetailDialog> {
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TextEditingController _voiceController;
  late TextEditingController _receiptController;
  late bool _isUpload;
  ExpenseCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    // Format with thousand separators for IDR
    final formattedAmount = widget.transaction.amount
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    _amountController = TextEditingController(text: formattedAmount);
    _descriptionController = TextEditingController(
      text: widget.transaction.description ?? '',
    );
    _voiceController = TextEditingController(
      text: widget.transaction.voiceNotePath ?? '',
    );
    _receiptController = TextEditingController(
      text: widget.transaction.receiptImagePath ?? '',
    );
    _isUpload = widget.transaction.isUpload;
    _selectedCategory = widget.transaction.expenseCategory;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _voiceController.dispose();
    _receiptController.dispose();
    super.dispose();
  }

  void _onSave() {
    // Remove thousand separator (dots) and any non-numeric characters before parsing
    final cleanAmount = _amountController.text
        .replaceAll('.', '')
        .replaceAll(',', '');
    final parsed = double.tryParse(cleanAmount) ?? widget.transaction.amount;
    final updated = TransactionEntity(
      id: widget.transaction.id,
      amount: parsed,
      tanggal: widget.transaction.tanggal,
      isUpload: _isUpload,
      type: widget.transaction.type,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      expenseCategory: widget.transaction.type == TypeTransaction.pengeluaran
          ? _selectedCategory
          : null,
      receiptImagePath: _receiptController.text.isEmpty
          ? null
          : _receiptController.text,
      voiceNotePath: _voiceController.text.isEmpty
          ? null
          : _voiceController.text,
      place: widget.transaction.place,
      dompetmonthid: widget.transaction.dompetmonthid,
    );

    Navigator.of(context).pop(TransactionDialogResult.save(updated));
  }

  @override
  Widget build(BuildContext context) {
    final isPengeluaran =
        widget.transaction.type == TypeTransaction.pengeluaran;

    return AlertDialog(
      title: const Text('Edit Transaksi'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isPengeluaran
                    ? Colors.red.shade100
                    : Colors.green.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.transaction.type.typeText,
                style: TextStyle(
                  color: isPengeluaran
                      ? Colors.red.shade800
                      : Colors.green.shade800,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 12),

            // Description field (editable)
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Tambahkan catatan...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Category dropdown (only for pengeluaran)
            if (isPengeluaran) ...[
              const Text(
                'Kategori',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ExpenseCategory>(
                    isExpanded: true,
                    value: _selectedCategory,
                    hint: const Text('Pilih kategori'),
                    items: ExpenseCategory.values
                        .map(
                          (cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedCategory = value),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Read-only meta fields
            Text(
              'Tanggal: ${widget.transaction.tanggal.day}/${widget.transaction.tanggal.month}/${widget.transaction.tanggal.year}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),

            // Uploaded status
            Row(
              children: [
                const Text('Uploaded:', style: TextStyle(color: Colors.grey)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _isUpload
                        ? Colors.green.shade100
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _isUpload ? 'Yes' : 'No',
                    style: TextStyle(
                      color: _isUpload
                          ? Colors.green.shade800
                          : Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_receiptController.text.isNotEmpty) ...[
              const Text('Receipt:', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              SizedBox(
                height: 140,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_receiptController.text),
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Image.network(
                      _receiptController.text,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                          const Text('Gagal memuat gambar'),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Konfirmasi Hapus'),
                content: const Text('Yakin ingin menghapus transaksi ini?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Hapus'),
                  ),
                ],
              ),
            );
            if (!context.mounted) return;
            if (confirm == true) {
              Navigator.of(context).pop(TransactionDialogResult.delete());
            }
          },
          child: const Text('Hapus', style: TextStyle(color: Colors.red)),
        ),
        ElevatedButton(onPressed: _onSave, child: const Text('Simpan')),
      ],
    );
  }
}

class TransactionDialogResult {
  final TransactionEntity? entity;
  final bool deleted;

  const TransactionDialogResult._({this.entity, required this.deleted});

  factory TransactionDialogResult.save(TransactionEntity entity) =>
      TransactionDialogResult._(entity: entity, deleted: false);
  factory TransactionDialogResult.delete() =>
      const TransactionDialogResult._(entity: null, deleted: true);
}
