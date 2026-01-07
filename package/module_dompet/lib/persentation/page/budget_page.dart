import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_core/constant/constant.dart';
import 'package:module_dompet/persentation/bloc/budget_bloc.dart';
import 'package:module_dompet/persentation/bloc/budget_event.dart';
import 'package:module_dompet/persentation/bloc/budget_state.dart';
import 'package:module_dompet/persentation/bloc/dompet_bloc.dart';
import 'package:module_dompet/persentation/bloc/transaction_bloc.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    _loadBudgets();
  }

  void _loadBudgets() {
    final dompetState = context.read<DompetBloc>().state;
    if (dompetState is DompetLoaded) {
      context.read<BudgetBloc>().add(
        LoadBudgets(
          dompetId: dompetState.dompet.id,
          month: _selectedMonth,
          year: _selectedYear,
        ),
      );
    }
  }

  void _previousMonth() {
    setState(() {
      if (_selectedMonth == 1) {
        _selectedMonth = 12;
        _selectedYear--;
      } else {
        _selectedMonth--;
      }
    });
    _loadBudgets();
  }

  void _nextMonth() {
    setState(() {
      if (_selectedMonth == 12) {
        _selectedMonth = 1;
        _selectedYear++;
      } else {
        _selectedMonth++;
      }
    });
    _loadBudgets();
  }

  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
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
    // Listen for transaction changes to reload budget data
    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        // Reload budgets when a transaction is inserted, updated or deleted
        if (state is TransactionSuccess) {
          _loadBudgets();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF16213E),
          elevation: 0,
          title: const Text(
            'Anggaran Bulanan',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF4A90E2),
          onPressed: _showAddBudgetDialog,
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: Column(
          children: [
            // Month Selector
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _previousMonth,
                    icon: const Icon(Icons.chevron_left, color: Colors.white),
                  ),
                  Text(
                    '${_getMonthName(_selectedMonth)} $_selectedYear',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: _nextMonth,
                    icon: const Icon(Icons.chevron_right, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Budget List
            Expanded(
              child: BlocBuilder<BudgetBloc, BudgetState>(
                builder: (context, state) {
                  if (state is BudgetLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4A90E2),
                      ),
                    );
                  }

                  if (state is BudgetError) {
                    return Center(
                      child: Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (state is BudgetLoaded) {
                    if (state.budgets.isEmpty) {
                      return _buildEmptyState();
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.budgets.length,
                      itemBuilder: (context, index) {
                        return _buildBudgetCard(state.budgets[index]);
                      },
                    );
                  }

                  return _buildEmptyState();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Colors.white38,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada anggaran',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + untuk menambah batas anggaran per kategori',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard(BudgetLimitData budget) {
    final color = _getCategoryColor(budget.category);
    final isOverLimit = budget.isOverLimit;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOverLimit
              ? Colors.red.withValues(alpha: 0.5)
              : Colors.white24,
          width: isOverLimit ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getCategoryIcon(budget.category),
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.category.label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${_formatCurrency(budget.currentSpent)} / ${_formatCurrency(budget.limitAmount)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: isOverLimit ? Colors.red : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
              // Edit/Delete buttons
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white54),
                color: const Color(0xFF16213E),
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditBudgetDialog(budget);
                  } else if (value == 'delete') {
                    _deleteBudget(budget.id);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.white70, size: 20),
                        SizedBox(width: 8),
                        Text('Edit', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: budget.percentage / 100,
                    backgroundColor: Colors.white24,
                    valueColor: AlwaysStoppedAnimation(
                      isOverLimit ? Colors.red : color,
                    ),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isOverLimit
                      ? Colors.red.withValues(alpha: 0.2)
                      : color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${budget.percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isOverLimit ? Colors.red : color,
                  ),
                ),
              ),
            ],
          ),

          // Warning message if over limit
          if (isOverLimit) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.red, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Anda sudah melebihi batas anggaran!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showAddBudgetDialog() {
    final dompetState = context.read<DompetBloc>().state;
    if (dompetState is! DompetLoaded) return;

    ExpenseCategory? selectedCategory;
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          'Tambah Anggaran',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category dropdown
            DropdownButtonFormField<ExpenseCategory>(
              dropdownColor: const Color(0xFF16213E),
              decoration: InputDecoration(
                labelText: 'Kategori',
                labelStyle: TextStyle(color: Colors.grey.shade400),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
              ),
              items: ExpenseCategory.values
                  .map(
                    (cat) => DropdownMenuItem(
                      value: cat,
                      child: Row(
                        children: [
                          Icon(
                            _getCategoryIcon(cat),
                            color: _getCategoryColor(cat),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cat.label,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => selectedCategory = value,
            ),
            const SizedBox(height: 16),
            // Amount field
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Batas Anggaran',
                labelStyle: TextStyle(color: Colors.grey.shade400),
                prefixText: 'Rp ',
                prefixStyle: const TextStyle(color: Colors.white70),
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
                  borderSide: const BorderSide(color: Color(0xFF4A90E2)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade400)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
            ),
            onPressed: () {
              if (selectedCategory != null &&
                  amountController.text.isNotEmpty) {
                final amount =
                    double.tryParse(
                      amountController.text.replaceAll('.', ''),
                    ) ??
                    0;
                if (amount > 0) {
                  context.read<BudgetBloc>().add(
                    SaveBudgetLimit(
                      dompetId: (dompetState).dompet.id,
                      category: selectedCategory!,
                      limitAmount: amount,
                      month: _selectedMonth,
                      year: _selectedYear,
                    ),
                  );
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditBudgetDialog(BudgetLimitData budget) {
    final dompetState = context.read<DompetBloc>().state;
    if (dompetState is! DompetLoaded) return;

    final amountController = TextEditingController(
      text: budget.limitAmount.toStringAsFixed(0),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: Text(
          'Edit ${budget.category.label}',
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Batas Anggaran',
            labelStyle: TextStyle(color: Colors.grey.shade400),
            prefixText: 'Rp ',
            prefixStyle: const TextStyle(color: Colors.white70),
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
              borderSide: const BorderSide(color: Color(0xFF4A90E2)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade400)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
            ),
            onPressed: () {
              final amount =
                  double.tryParse(amountController.text.replaceAll('.', '')) ??
                  0;
              if (amount > 0) {
                context.read<BudgetBloc>().add(
                  SaveBudgetLimit(
                    dompetId: (dompetState).dompet.id,
                    category: budget.category,
                    limitAmount: amount,
                    month: _selectedMonth,
                    year: _selectedYear,
                  ),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteBudget(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text(
          'Hapus Anggaran?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Anggaran ini akan dihapus permanen',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade400)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<BudgetBloc>().add(DeleteBudgetLimit(id));
              Navigator.pop(context);
              _loadBudgets();
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
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
