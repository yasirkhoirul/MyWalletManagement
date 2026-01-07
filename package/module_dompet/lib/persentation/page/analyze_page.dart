import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_core/constant/constant.dart';
import 'package:module_dompet/persentation/bloc/analyze_bloc.dart';
import 'package:module_dompet/persentation/bloc/analyze_event.dart';
import 'package:module_dompet/persentation/bloc/analyze_state.dart';
import 'package:module_dompet/persentation/bloc/dompet_bloc.dart';
import 'package:module_dompet/persentation/bloc/transaction_bloc.dart';

class AnalyzePage extends StatefulWidget {
  const AnalyzePage({super.key});

  @override
  State<AnalyzePage> createState() => _AnalyzePageState();
}

class _AnalyzePageState extends State<AnalyzePage> {
  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;

    // Load data when dompet is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalyzeData();
    });
  }

  void _loadAnalyzeData() {
    final dompetState = context.read<DompetBloc>().state;
    if (dompetState is DompetLoaded) {
      context.read<AnalyzeBloc>().add(
        LoadAnalyzeData(dompetState.dompet.id, _selectedMonth, _selectedYear),
      );
    }
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
    // Listen for transaction changes to reload analyze data
    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionSuccess) {
          // Reload analyze data when transaction is added/updated/deleted
          _loadAnalyzeData();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          title: const Text('Analisis Keuangan'),
          backgroundColor: const Color(0xFF16213E),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: BlocBuilder<AnalyzeBloc, AnalyzeState>(
          builder: (context, state) {
            if (state is AnalyzeLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (state is AnalyzeError) {
              return Center(
                child: Text(
                  'Error: ${state.message}',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }

            if (state is AnalyzeLoaded) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month selector
                    _buildMonthSelector(),
                    const SizedBox(height: 24),

                    // Peak spending insight
                    if (state.highestSpendingDay != null)
                      _buildPeakSpendingCard(state),
                    const SizedBox(height: 24),

                    // Heatmap calendar
                    const Text(
                      'Peta Panas Pengeluaran',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Warna lebih gelap = pengeluaran lebih tinggi',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildHeatmapCalendar(state),
                    const SizedBox(height: 24),

                    // Category breakdown
                    const Text(
                      'Pengeluaran per Kategori',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCategoryBreakdown(state),
                  ],
                ),
              );
            }

            return const Center(
              child: Text(
                'Pilih bulan untuk melihat analisis',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.white),
            onPressed: () {
              setState(() {
                if (_selectedMonth == 1) {
                  _selectedMonth = 12;
                  _selectedYear--;
                } else {
                  _selectedMonth--;
                }
              });
              _loadAnalyzeData();
            },
          ),
          Text(
            '${months[_selectedMonth - 1]} $_selectedYear',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.white),
            onPressed: () {
              setState(() {
                if (_selectedMonth == 12) {
                  _selectedMonth = 1;
                  _selectedYear++;
                } else {
                  _selectedMonth++;
                }
              });
              _loadAnalyzeData();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPeakSpendingCard(AnalyzeLoaded state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade400, Colors.red.shade400],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.white, size: 28),
              const SizedBox(width: 8),
              const Text(
                'Pengeluaran Tertinggi',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Tanggal ${state.highestSpendingDay}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatCurrency(state.highestSpendingAmount),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapCalendar(AnalyzeLoaded state) {
    // Calculate max spending for color intensity
    double maxSpending = 0;
    state.dailySpending.values.forEach((v) {
      if (v > maxSpending) maxSpending = v;
    });

    // Get days in month
    final daysInMonth = DateTime(_selectedYear, _selectedMonth + 1, 0).day;
    final firstDayWeekday = DateTime(_selectedYear, _selectedMonth, 1).weekday;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min']
                .map(
                  (d) => SizedBox(
                    width: 36,
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),

          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: (firstDayWeekday - 1) + daysInMonth,
            itemBuilder: (context, index) {
              // Empty cells for offset
              if (index < firstDayWeekday - 1) {
                return const SizedBox();
              }

              final day = index - (firstDayWeekday - 1) + 1;
              final spending = state.dailySpending[day] ?? 0;

              // Calculate color intensity
              double intensity = maxSpending > 0 ? spending / maxSpending : 0;

              return Tooltip(
                message: _formatCurrency(spending),
                child: Container(
                  decoration: BoxDecoration(
                    color: spending > 0
                        ? Colors.red.withValues(alpha: 0.3 + (intensity * 0.7))
                        : const Color(0xFF0F3460),
                    borderRadius: BorderRadius.circular(6),
                    border: state.highestSpendingDay == day
                        ? Border.all(color: Colors.orange, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: spending > 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown(AnalyzeLoaded state) {
    if (state.categorySpending.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: const Center(
          child: Text(
            'Belum ada data pengeluaran',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    // Calculate total
    double total = 0;
    state.categorySpending.values.forEach((v) => total += v);

    // Sort by amount
    final sorted = state.categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      children: sorted.map((entry) {
        final percentage = total > 0 ? (entry.value / total * 100) : 0;
        final color = _getCategoryColor(entry.key);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(entry.key),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation(color),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(entry.value),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
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
