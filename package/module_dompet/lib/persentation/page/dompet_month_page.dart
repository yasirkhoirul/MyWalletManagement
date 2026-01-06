import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/web.dart';
import 'package:module_dompet/persentation/bloc/dompet_month_bloc.dart';
import 'package:module_dompet/persentation/bloc/transaction_list_bloc.dart';
import 'package:module_dompet/persentation/bloc/transaction_bloc.dart';
import 'package:module_dompet/persentation/widget/transaction_detail_dialog.dart';
import 'package:module_core/constant/constant.dart';
import 'package:module_dompet/domain/entities/transaction_entity.dart';

class DompetMonthPage extends StatefulWidget {
  const DompetMonthPage({super.key});

  @override
  State<DompetMonthPage> createState() => _DompetMonthPageState();
}

class _DompetMonthPageState extends State<DompetMonthPage> with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    // load transactions when user navigates to transactions page
    context.read<TransactionListBloc>().add(GetListTransaction());
    context.read<DompetMonthBloc>().add(GetDompetMonthsEvent(1));
    _pageController = PageController(initialPage: 0);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  String _getMonthName(int month) {
    const monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return monthNames[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          onTap: (index) {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          tabs: const [
            Tab(text: 'Bulanan'),
            Tab(text: 'Harian'),
          ],
        ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          _tabController.animateTo(index);
          Logger().d("index page saat ini adalah $index");
        },
        children: [
                // Page 0: Monthly dompet list
                BlocListener<DompetMonthBloc, DompetMonthState>(
                  listener: (context, state) {
                    if (state is DompetMonthActionSuccess) {
                      showDialog<void>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Berhasil'),
                          content: Text(state.message),
                          actions: [
                            TextButton(
                              onPressed: () => context.pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    } else if (state is DompetMonthActionFailure) {
                      showDialog<void>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Gagal'),
                          content: Text(state.message),
                          actions: [
                            TextButton(
                              onPressed: () => context.pop(),
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  child: BlocBuilder<DompetMonthBloc, DompetMonthState>(
                    builder: (context, state) {
                      if (state is DompetMonthLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is DompetMonthSuccess) {
                        if (state.months.isEmpty) {
                          return const Center(
                            child: Text('Belum ada data bulanan'),
                          );
                        }
            
                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.months.length,
                          itemBuilder: (context, index) {
                            final month = state.months[index];
                            final balance = month.pemasukkan - month.pengeluaran;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Month and Year
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${_getMonthName(month.month)} ${month.year}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Icon(
                                          balance >= 0 ? Icons.trending_up : Icons.trending_down,
                                          color: balance >= 0 ? Colors.green : Colors.red,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
            
                                    // Pemasukkan
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.arrow_downward, color: Colors.green, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              'Pemasukkan',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Rp ${month.pemasukkan.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
            
                                    // Pengeluaran
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.arrow_upward, color: Colors.red, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              'Pengeluaran',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          'Rp ${month.pengeluaran.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
            
                                    const Divider(height: 24),
            
                                    // Balance
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Saldo',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'Rp ${balance.toStringAsFixed(0)}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: balance >= 0 ? Colors.green : Colors.red,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Delete button or loading indicator
                                            if (month.id != null)
                                              state.deletingIds.contains(month.id)
                                                  ? const SizedBox(
                                                      width: 20,
                                                      height: 20,
                                                      child: CircularProgressIndicator(strokeWidth: 2),
                                                    )
                                                  : IconButton(
                                                      tooltip: 'Delete month',
                                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                                      onPressed: () {
                                                        context.read<DompetMonthBloc>().add(DeleteDompetMonthEvent(month.id!));
                                                      },
                                                    ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      } else if (state is DompetMonthError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 16),
                              Text('Error: ${state.message}'),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<DompetMonthBloc>().add(GetDompetMonthsEvent(1));
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }
            
                      return const Center(child: Text('No data'));
                    },
                  ),
                ),
            
                // Page 1: Daily transactions
                BlocBuilder<TransactionListBloc, TransactionListState>(
                  builder: (context, state) {
                    if (state is TransactionListLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is TransactionListSuccess) {
                      final List<TransactionEntity> txs = state.transactions;
                      if (txs.isEmpty) return const Center(child: Text('Belum ada transaksi'));

                      // Group by date (year-month-day)
                      final Map<DateTime, List<TransactionEntity>> grouped = {};
                      for (final t in txs) {
                        final dateKey = DateTime(t.tanggal.year, t.tanggal.month, t.tanggal.day);
                        grouped.putIfAbsent(dateKey, () => []).add(t);
                      }

                      // Sort dates descending
                      final dates = grouped.keys.toList()
                        ..sort((a, b) => b.compareTo(a));

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: dates.length,
                        itemBuilder: (context, idx) {
                          final date = dates[idx];
                          final items = grouped[date]!;
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${date.day}-${date.month}-${date.year}',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 8),
                                  ...items.map((tx) => ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: tx.type == TypeTransaction.pemasukkan ? Colors.green[100] : Colors.red[100],
                                          child: Icon(
                                            tx.type == TypeTransaction.pemasukkan ? Icons.arrow_downward : Icons.arrow_upward,
                                            color: tx.type == TypeTransaction.pemasukkan ? Colors.green : Colors.red,
                                          ),
                                        ),
                                        title: Text('Rp ${tx.amount.toStringAsFixed(0)} '),
                                        subtitle: Text(tx.tanggal.toLocal().toString()),
                                        trailing: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              (tx.type == TypeTransaction.pemasukkan ? '+ ' : '- ') + 'Rp ${tx.amount.toStringAsFixed(0)}',
                                              style: TextStyle(
                                                color: tx.type == TypeTransaction.pemasukkan ? Colors.green : Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: tx.isUpload ? Colors.green.shade100 : Colors.grey.shade300,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                tx.isUpload ? 'Uploaded' : 'Pending',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: tx.isUpload ? Colors.green.shade800 : Colors.grey.shade800,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        onTap: () async {
                                          final result = await showDialog<TransactionDialogResult?>(
                                            context: context,
                                            builder: (_) => TransactionDetailDialog(transaction: tx),
                                          );
                                          if (result != null) {
                                            if (result.deleted) {
                                              // delete
                                              final id = tx.id;
                                              if (id != null) {
                                                context.read<TransactionBloc>().add(DeleteTransactionEvent(id));
                                                if (mounted) {
                                                  final messenger = ScaffoldMessenger.maybeOf(context);
                                                  messenger?.showSnackBar(const SnackBar(content: Text('Transaksi dihapus')));
                                                }
                                              } else {
                                                if (mounted) {
                                                  final messenger = ScaffoldMessenger.maybeOf(context);
                                                  messenger?.showSnackBar(const SnackBar(content: Text('Tidak dapat menghapus: ID tidak tersedia')));
                                                }
                                              }
                                            } else if (result.entity != null) {
                                              // update
                                              try {
                                                context.read<TransactionBloc>().add(UpdateTransactionEvent(result.entity!, 1));
                                                if (mounted) {
                                                  final messenger = ScaffoldMessenger.maybeOf(context);
                                                  messenger?.showSnackBar(const SnackBar(content: Text('Perubahan disimpan')));
                                                }
                                              } catch (_) {}
                                            }
                                          }
                                        },
                                      )).toList(),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    } else if (state is TransactionListError) {
                      return Center(child: Text('Error: ${state.message}'));
                    }
                    return const Center(child: Text('No data'));
                  },
                ),
              ],
            ),
    );
  }
}
