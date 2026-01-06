import 'dart:io';
import 'package:flutter/material.dart';
import 'package:module_dompet/domain/entities/transaction_entity.dart';

class TransactionDetailDialog extends StatefulWidget {
  final TransactionEntity transaction;
  const TransactionDetailDialog({super.key, required this.transaction});

  @override
  State<TransactionDetailDialog> createState() => _TransactionDetailDialogState();
}

class _TransactionDetailDialogState extends State<TransactionDetailDialog> {
  late TextEditingController _amountController;
  late TextEditingController _voiceController;
  late TextEditingController _receiptController;
  late bool _isUpload;

  @override
  void initState() {
    super.initState();
    // Format with thousand separators for IDR
    final formattedAmount = widget.transaction.amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.'
    );
    _amountController = TextEditingController(text: formattedAmount);
    _voiceController = TextEditingController(text: widget.transaction.voiceNotePath ?? '');
    _receiptController = TextEditingController(text: widget.transaction.receiptImagePath ?? '');
    _isUpload = widget.transaction.isUpload;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _voiceController.dispose();
    _receiptController.dispose();
    super.dispose();
  }

  void _onSave() {
    final parsed = double.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? widget.transaction.amount;
    final updated = TransactionEntity(
      id: widget.transaction.id,
      amount: parsed,
      tanggal: widget.transaction.tanggal,
      isUpload: _isUpload,
      type: widget.transaction.type,
      receiptImagePath: _receiptController.text.isEmpty ? null : _receiptController.text,
      voiceNotePath: _voiceController.text.isEmpty ? null : _voiceController.text,
      place: widget.transaction.place,
      dompetmonthid: widget.transaction.dompetmonthid,
    );

    Navigator.of(context).pop(TransactionDialogResult.save(updated));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Transaksi'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 8),
            // Read-only meta fields
            Text('ID: ${widget.transaction.id ?? '-'}'),
            const SizedBox(height: 8),
            Text('Type: ${widget.transaction.type.typeText}'),
            const SizedBox(height: 8),
            Text('Date: ${widget.transaction.tanggal.toLocal()}'),
            const SizedBox(height: 8),
            Text('Place: ${widget.transaction.place?.toString() ?? '-'}'),
            const SizedBox(height: 8),
            // Uploaded is read-only — show status only
            Row(
              children: [
                const Text('Uploaded:'),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _isUpload ? Colors.green.shade100 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _isUpload ? 'Yes' : 'No',
                    style: TextStyle(
                      color: _isUpload ? Colors.green.shade800 : Colors.grey.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _voiceController,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Voice note path / text'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _receiptController,
              decoration: const InputDecoration(labelText: 'Receipt image path'),
            ),
            const SizedBox(height: 12),
            if (_receiptController.text.isNotEmpty)
              SizedBox(
                height: 140,
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_receiptController.text),
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => const Text('Gagal memuat gambar'),
                  ),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        TextButton(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Konfirmasi Hapus'),
                content: const Text('Yakin ingin menghapus transaksi ini?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
                  ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
                ],
              ),
            );
              if(!context.mounted)return;
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

  factory TransactionDialogResult.save(TransactionEntity entity) => TransactionDialogResult._(entity: entity, deleted: false);
  factory TransactionDialogResult.delete() => const TransactionDialogResult._(entity: null, deleted: true);
}
