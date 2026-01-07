import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:module_core/constant/constant.dart';
import 'package:module_dompet/data/datasource/voice_remote_datasource.dart';
import 'package:module_dompet/domain/entities/transaction_entity.dart';
import 'package:module_dompet/persentation/bloc/dompet_bloc.dart';
import 'package:module_dompet/persentation/bloc/transaction_bloc.dart';
import 'package:module_dompet/persentation/bloc/transaction_list_bloc.dart';
import 'package:module_dompet/persentation/widget/initial_wallet_dialog.dart';
import 'package:module_dompet/persentation/widget/voice_recording_sheet.dart';
import 'package:image_picker/image_picker.dart';

// Custom formatter untuk IDR currency
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Hanya ambil angka
    final numericText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (numericText.isEmpty) {
      return const TextEditingValue();
    }

    // Format dengan thousand separator (titik)
    final buffer = StringBuffer();
    final length = numericText.length;

    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(numericText[i]);
    }

    final formattedText = buffer.toString();

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  final ImagePicker _imagePicker = ImagePicker();
  TypeTransaction _selectedType = TypeTransaction.pengeluaran;
  ExpenseCategory? _selectedCategory;
  String? _selectedImagePath;
  String? _selectedVoiceNote;
  bool _fabExpanded = false;
  bool _dialogShown = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();

    // Fetch transaction list on init
    context.read<TransactionListBloc>().add(GetListTransaction());

    // Handle query params from overview page navigation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleQueryParams();
    });
  }

  void _handleQueryParams() {
    final uri = GoRouterState.of(context).uri;
    final queryParams = uri.queryParameters;

    // Handle type param (pemasukkan/pengeluaran)
    final typeParam = queryParams['type'];
    if (typeParam != null) {
      setState(() {
        _selectedType = typeParam == 'pemasukkan'
            ? TypeTransaction.pemasukkan
            : TypeTransaction.pengeluaran;
      });
    }

    // Handle scan image param
    final scanImage = queryParams['scanImage'];
    if (scanImage != null && scanImage.isNotEmpty) {
      setState(() {
        _selectedImagePath = scanImage;
      });
      // Trigger receipt processing
      context.read<TransactionBloc>().add(ProcessReceiptEvent(File(scanImage)));
    }

    // Handle voice params
    final voiceAmount = queryParams['voiceAmount'];
    final voiceDesc = queryParams['voiceDesc'];
    final voiceCat = queryParams['voiceCat'];

    if (voiceAmount != null && voiceAmount.isNotEmpty && voiceAmount != '0') {
      setState(() {
        _amountController.text = voiceAmount;
      });
    }
    if (voiceDesc != null && voiceDesc.isNotEmpty) {
      setState(() {
        _descriptionController.text = Uri.decodeComponent(voiceDesc);
      });
    }
    if (voiceCat != null && voiceCat.isNotEmpty) {
      final cat = ExpenseCategory.values
          .where((c) => c.name.toLowerCase() == voiceCat.toLowerCase())
          .firstOrNull;
      if (cat != null) {
        setState(() {
          _selectedCategory = cat;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatCurrency(double amount) {
    final amountStr = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    final length = amountStr.length;
    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(amountStr[i]);
    }
    return 'Rp $buffer';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      floatingActionButton: SizedBox(
        width: 72,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            // Animated mini-FABs
            Positioned(
              right: 8,
              bottom: 72,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _fabExpanded ? 1 : 0,
                child: IgnorePointer(
                  ignoring: !_fabExpanded,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        children: [
                          FloatingActionButton.small(
                            heroTag: 'voice',
                            onPressed: () {
                              setState(() => _fabExpanded = false);
                              _showVoiceInputDialog();
                            },
                            tooltip: 'Input Voice',
                            child: const Icon(Icons.mic),
                          ),
                          const SizedBox(height: 4),
                          const Text('Suara', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          FloatingActionButton.small(
                            heroTag: 'photo',
                            onPressed: () {
                              setState(() => _fabExpanded = false);
                              _processReceiptImage();
                            },
                            tooltip: 'Input Photo',
                            child: const Icon(Icons.camera_alt),
                          ),
                          const SizedBox(height: 4),
                          const Text('Foto', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Main FAB
            Positioned(
              right: 8,
              bottom: 8,
              child: FloatingActionButton(
                onPressed: () => setState(() => _fabExpanded = !_fabExpanded),
                tooltip: _fabExpanded ? 'Close' : 'Open',
                child: AnimatedRotation(
                  turns: _fabExpanded ? 0.125 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Text("AI"),
                ),
              ),
            ),
          ],
        ),
      ),
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is ProcessReceiptLoading) {
            // Show loading indicator
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder: (context) => const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Memproses struk...'),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else if (state is ProcessReceiptSuccess) {
            // Close loading dialog
            context.pop();

            // Populate form fields with receipt data
            final receipt = state.receipt;
            if (receipt.amount != null) {
              final formattedAmount = receipt.amount!
                  .toStringAsFixed(0)
                  .replaceAllMapped(
                    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                    (match) => '${match[1]}.',
                  );
              _amountController.text = formattedAmount;
            }
            if (receipt.description != null) {
              _descriptionController.text = receipt.description!;
            }
            if (receipt.category != null) {
              setState(() {
                _selectedCategory = receipt.category;
              });
            }

            // Show success message
            if (mounted) {
              final messenger = ScaffoldMessenger.maybeOf(context);
              messenger?.showSnackBar(
                const SnackBar(content: Text('Struk berhasil diproses')),
              );
            }
          } else if (state is ProcessReceiptError) {
            // Close loading dialog if open
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }

            // Show error dialog
            _showReceiptErrorDialog(state.message);
          }
        },
        child: BlocListener<DompetBloc, DompetState>(
          listener: (context, state) {
            // Show dialog when dompet not found (first time user)
            if (state is DompetNotFound && !_dialogShown) {
              _dialogShown = true;
              InitialWalletDialog.show(context, state.userId);
            }
          },
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Balance Card with real data from DompetBloc
                BlocBuilder<DompetBloc, DompetState>(
                  builder: (context, state) {
                    double balance = 0;
                    double pemasukkan = 0;
                    double pengeluaran = 0;

                    if (state is DompetLoaded) {
                      balance = state.dompet.balance;
                      pemasukkan = state.dompet.pemasukkan;
                      pengeluaran = state.dompet.pengeluaran;
                    }

                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.purple.shade300,
                              Colors.cyan.shade300,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Balance',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                if (state is DompetLoading)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatCurrency(balance),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Income and Expense row
                            Row(
                              children: [
                                // Income
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_downward,
                                          color: Colors.greenAccent,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Pemasukkan',
                                            style: TextStyle(
                                              color: Colors.white60,
                                              fontSize: 11,
                                            ),
                                          ),
                                          Text(
                                            _formatCurrency(pemasukkan),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Expense
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_upward,
                                          color: Colors.redAccent,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Pengeluaran',
                                            style: TextStyle(
                                              color: Colors.white60,
                                              fontSize: 11,
                                            ),
                                          ),
                                          Text(
                                            _formatCurrency(pengeluaran),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                // Form Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Amount Field
                      Text(
                        'Jumlah',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          ThousandsSeparatorInputFormatter(),
                        ],
                        decoration: InputDecoration(
                          prefixText: 'Rp ',
                          prefixStyle: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                          hintText: '0',
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: const Color(0xFF16213E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF4A90E2),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Transaction Type
                      Text(
                        'Tipe Transaksi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(
                                () =>
                                    _selectedType = TypeTransaction.pemasukkan,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _selectedType ==
                                          TypeTransaction.pemasukkan
                                      ? Colors.green
                                      : const Color(0xFF16213E),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        _selectedType ==
                                            TypeTransaction.pemasukkan
                                        ? Colors.green
                                        : Colors.white24,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_downward,
                                      color:
                                          _selectedType ==
                                              TypeTransaction.pemasukkan
                                          ? Colors.white
                                          : Colors.white54,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Pemasukkan',
                                      style: TextStyle(
                                        color:
                                            _selectedType ==
                                                TypeTransaction.pemasukkan
                                            ? Colors.white
                                            : Colors.white54,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(
                                () =>
                                    _selectedType = TypeTransaction.pengeluaran,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      _selectedType ==
                                          TypeTransaction.pengeluaran
                                      ? Colors.red
                                      : const Color(0xFF16213E),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        _selectedType ==
                                            TypeTransaction.pengeluaran
                                        ? Colors.red
                                        : Colors.white24,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_upward,
                                      color:
                                          _selectedType ==
                                              TypeTransaction.pengeluaran
                                          ? Colors.white
                                          : Colors.white54,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Pengeluaran',
                                      style: TextStyle(
                                        color:
                                            _selectedType ==
                                                TypeTransaction.pengeluaran
                                            ? Colors.white
                                            : Colors.white54,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Description Field
                      Text(
                        'Catatan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Tambahkan catatan...',
                          hintStyle: TextStyle(color: Colors.grey.shade600),
                          filled: true,
                          fillColor: const Color(0xFF16213E),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF4A90E2),
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),

                      // Expense Category (only for pengeluaran)
                      if (_selectedType == TypeTransaction.pengeluaran) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Kategori',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 4,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.9,
                          children: ExpenseCategory.values.map((cat) {
                            final isSelected = _selectedCategory == cat;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedCategory = cat),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? _getCategoryColor(cat)
                                      : const Color(0xFF16213E),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? _getCategoryColor(cat)
                                        : Colors.white24,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _getCategoryIcon(cat),
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white70,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      cat.label,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.white70,
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Receipt Image
                      const Text(
                        'Receipt Image (Optional)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (_selectedImagePath != null) ...[
                        // Image Preview
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              children: [
                                Image.file(
                                  File(_selectedImagePath!),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.black54,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _selectedImagePath = null;
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],

                      // Pick Image Button
                      OutlinedButton.icon(
                        onPressed: _showImageSourceDialog,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: Text(
                          _selectedImagePath == null
                              ? 'Pilih Gambar Bukti'
                              : 'Ganti Gambar',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Process Button
                      SizedBox(
                        width: double.infinity,
                        child: BlocListener<TransactionBloc, TransactionState>(
                          listener: (context, state) {
                            if (state is TransactionSuccess) {
                              if (mounted) {
                                final messenger = ScaffoldMessenger.maybeOf(
                                  context,
                                );
                                messenger?.showSnackBar(
                                  SnackBar(content: Text(state.message)),
                                );
                              }
                              _amountController.clear();
                              _descriptionController.clear();
                              setState(() {
                                _selectedImagePath = null;
                                _selectedCategory = null;
                              });
                            } else if (state is TransactionError) {
                              if (mounted) {
                                final messenger = ScaffoldMessenger.maybeOf(
                                  context,
                                );
                                messenger?.showSnackBar(
                                  SnackBar(
                                    content: Text(state.message),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => _processTransaction(),
                            child: const Text(
                              'Process',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ), // Close BlocListener for DompetBloc
      ), // Close BlocListener for TransactionBloc
    );
  }

  void _processTransaction() {
    // Hapus thousand separator (titik) sebelum parsing
    final amount =
        double.tryParse(
          _amountController.text.replaceAll('.', '').replaceAll(',', ''),
        ) ??
        0;
    if (amount == 0) {
      if (mounted) {
        final messenger = ScaffoldMessenger.maybeOf(context);
        messenger?.showSnackBar(
          const SnackBar(content: Text('Please enter a valid amount')),
        );
      }
      return;
    }

    final now = DateTime.now();
    final nextMonth = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
      now.microsecond,
    );

    final entity = TransactionEntity(
      amount: amount,
      tanggal: nextMonth,
      isUpload: false,
      type: _selectedType,
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : null,
      expenseCategory: _selectedType == TypeTransaction.pengeluaran
          ? _selectedCategory
          : null,
      receiptImagePath: _selectedImagePath,
      voiceNotePath: _selectedVoiceNote,
      place: null,
      dompetmonthid: 0, // Will be set by upsertDompetMonth
    );
    // Get dompetId from DompetBloc
    final dompetState = context.read<DompetBloc>().state;
    if (dompetState is! DompetLoaded) {
      if (mounted) {
        final messenger = ScaffoldMessenger.maybeOf(context);
        messenger?.showSnackBar(
          const SnackBar(content: Text('Dompet belum tersedia')),
        );
      }
      return;
    }

    context.read<TransactionBloc>().add(
      InsertTransactionEvent(entity, dompetState.dompet.id),
    );
  }

  Future<void> _showImageSourceDialog() async {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Sumber Gambar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        final messenger = ScaffoldMessenger.maybeOf(context);
        messenger?.showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  Future<void> _showVoiceInputDialog() async {
    // Show voice recording bottom sheet
    final voiceDataSource = VoiceRemoteDataSourceImpl();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoiceRecordingSheet(
        voiceDataSource: voiceDataSource,
        onResult: (result) {
          // Auto-fill form with AI result
          if (result.amount != null) {
            final formattedAmount = result.amount!
                .toStringAsFixed(0)
                .replaceAllMapped(
                  RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
                  (match) => '${match[1]}.',
                );
            _amountController.text = formattedAmount;
          }
          if (result.description != null) {
            _descriptionController.text = result.description!;
          }
          if (result.category != null) {
            setState(() {
              _selectedType = TypeTransaction.pengeluaran;
              _selectedCategory = result.category;
            });
          }

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Data suara berhasil diproses!')),
            );
          }
        },
      ),
    );
  }

  Future<void> _processReceiptImage() async {
    // Show image source dialog first
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Sumber Gambar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Kamera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });

        // Trigger receipt processing
        if (mounted) {
          context.read<TransactionBloc>().add(
            ProcessReceiptEvent(File(image.path)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final messenger = ScaffoldMessenger.maybeOf(context);
        messenger?.showSnackBar(
          SnackBar(content: Text('Gagal memilih gambar: $e')),
        );
      }
    }
  }

  void _showReceiptErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gagal Memproses Struk'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.makanan:
        return Colors.orange;
      case ExpenseCategory.transportasi:
        return Colors.blue;
      case ExpenseCategory.belanja:
        return Colors.pink;
      case ExpenseCategory.hiburan:
        return Colors.purple;
      case ExpenseCategory.kesehatan:
        return Colors.green;
      case ExpenseCategory.pendidikan:
        return Colors.indigo;
      case ExpenseCategory.tagihan:
        return Colors.red;
      case ExpenseCategory.lainnya:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.makanan:
        return Icons.restaurant;
      case ExpenseCategory.transportasi:
        return Icons.directions_car;
      case ExpenseCategory.belanja:
        return Icons.shopping_bag;
      case ExpenseCategory.hiburan:
        return Icons.movie;
      case ExpenseCategory.kesehatan:
        return Icons.medical_services;
      case ExpenseCategory.pendidikan:
        return Icons.school;
      case ExpenseCategory.tagihan:
        return Icons.receipt_long;
      case ExpenseCategory.lainnya:
        return Icons.more_horiz;
    }
  }
}
