import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/web.dart';
import 'package:module_core/constant/constant.dart';
import 'package:module_dompet/domain/entities/transaction_entity.dart';
import 'package:module_dompet/persentation/bloc/transaction_bloc.dart';
import 'package:module_dompet/persentation/bloc/transaction_list_bloc.dart';
import 'package:module_dompet/persentation/page/dompet_month_page.dart';
import 'package:image_picker/image_picker.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  final ImagePicker _imagePicker = ImagePicker();
  TypeTransaction _selectedType = TypeTransaction.pengeluaran;
  String? _selectedImagePath;
  String? _selectedVoiceNote;
  bool _fabExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _amountController = TextEditingController();
    _descriptionController = TextEditingController();
    
    // Fetch transaction list on init
    context.read<TransactionListBloc>().add(GetListTransaction());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                              _showImageSourceDialog();
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
                  child: const Icon(Icons.rocket),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          
          children: [
            // Balance Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.purple.shade300, Colors.cyan.shade300],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Balance',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '\$ 1500.10',
                      style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '0101 · 1104 · 2010 · 2021',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            // Form Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Amount Field
                  const Text('Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefixText: 'Rp ',
                      hintText: '0.00',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Minimal transfer 100,000',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),

            

                  const SizedBox(height: 16),

                  // Transaction Type
                  const Text('Transaction Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<TypeTransaction>(
                        value: _selectedType,
                        isExpanded: true,
                        items: TypeTransaction.values
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type.typeText),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedType = value!);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description Field
                  const Text('Description', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Add note...',
                      
                      
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Receipt Image
                  const Text('Receipt Image (Optional)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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
                                icon: const Icon(Icons.close, color: Colors.white),
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
                    label: Text(_selectedImagePath == null ? 'Pilih Gambar Bukti' : 'Ganti Gambar'),
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
                            final messenger = ScaffoldMessenger.maybeOf(context);
                            messenger?.showSnackBar(
                              SnackBar(content: Text(state.message)),
                            );
                            Logger().i("Berhasil dilakukan");
                          }
                          _amountController.clear();
                          _descriptionController.clear();
                          setState(() {
                            _selectedImagePath = null;
                          });
                        } else if (state is TransactionError) {
                          if (mounted) {
                            final messenger = ScaffoldMessenger.maybeOf(context);
                            messenger?.showSnackBar(
                              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
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
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Transaction List
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Text('Recent Transactions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            BlocBuilder<TransactionListBloc, TransactionListState>(
              builder: (context, state) {
                Logger().d("state saat ini $state");
                if (state is TransactionListLoading) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  );
                } else if (state is TransactionListSuccess) {
                  // Sort by date descending and take only 2 most recent
                  final recentTxs = state.transactions.toList()
                    ..sort((a, b) => b.tanggal.compareTo(a.tanggal));
                  final limitedTxs = recentTxs.take(2).toList();
                  Logger().d(limitedTxs.length);
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: limitedTxs.length,
                    itemBuilder: (context, index) {
                      final tx = limitedTxs[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Icon(
                            tx.type == TypeTransaction.pemasukkan
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                          ),
                        ),
                        title: Text('${tx.type.typeText} - Rp ${tx.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}'),
                        subtitle: Text(tx.tanggal.toString()),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                          context.read<TransactionBloc>().add(DeleteTransactionEvent(tx.id!));
                          },
                        ),
                      );
                    },
                  );
                } else if (state is TransactionListError) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error: ${state.message}'),
                  );
                }
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No transactions'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _processTransaction() {
    final amount = double.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
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
      now.month + 1,
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
      receiptImagePath: _selectedImagePath,
      voiceNotePath: _selectedVoiceNote,
      place: null,
      dompetmonthid: 0, // Will be set by upsertDompetMonth
    );

    context.read<TransactionBloc>().add(InsertTransactionEvent(entity, 1)); // 1 is temporary dompetId
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
    final controller = TextEditingController(text: _selectedVoiceNote);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Voice Input (simulated)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This dialog simulates voice input. Type text to save as voice note.'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedVoiceNote = controller.text.isEmpty ? null : controller.text;
              });
              Navigator.pop(context);
              if (_selectedVoiceNote != null && mounted) {
                final messenger = ScaffoldMessenger.maybeOf(context);
                messenger?.showSnackBar(
                  const SnackBar(content: Text('Voice note saved (simulated)')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}