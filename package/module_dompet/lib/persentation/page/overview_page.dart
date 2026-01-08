import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:module_core/constant/constant.dart';
import 'package:module_core/service/network/network_service.dart';
import 'package:module_core/service/notification/notification_service.dart';
import 'package:module_dompet/data/datasource/voice_remote_datasource.dart';
import 'package:module_dompet/data/model/receipt_result_model.dart';
import 'package:module_dompet/persentation/bloc/analyze_bloc.dart';
import 'package:module_dompet/persentation/bloc/analyze_event.dart';
import 'package:module_dompet/persentation/bloc/analyze_state.dart';
import 'package:module_dompet/persentation/bloc/dompet_bloc.dart';
import 'package:module_dompet/persentation/bloc/sync_bloc.dart';
import 'package:module_dompet/persentation/bloc/transaction_bloc.dart';
import 'package:module_dompet/persentation/widget/initial_wallet_dialog.dart';
import 'package:module_dompet/persentation/widget/voice_recording_sheet.dart';
import 'package:image_picker/image_picker.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage>
    with TickerProviderStateMixin {
  bool _dialogShown = false;
  StreamSubscription<bool>? _networkSub;
  bool _wasOffline = false;

  // Staggered animation controllers for 6 sections
  late AnimationController _animController;
  late List<Animation<double>> _fadeAnims;
  late List<Animation<Offset>> _slideAnims;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Setup staggered animations for 6 sections
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Create staggered animations for 6 items: welcome, balance, input cepat, menu cepat, pie, area
    _fadeAnims = List.generate(6, (i) {
      final start = i * 0.12;
      final end = start + 0.4;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });

    _slideAnims = List.generate(6, (i) {
      final start = i * 0.12;
      final end = start + 0.4;
      return Tween<Offset>(
        begin: const Offset(0, 0.15),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animController,
          curve: Interval(start, end.clamp(0.0, 1.0), curve: Curves.easeOut),
        ),
      );
    });

    // Start animation
    _animController.forward();

    // Get Firebase user ID and load dompet
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      context.read<DompetBloc>().add(LoadDompet(userId));
    }

    // Load analyze data after dompet loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalyzeData();
      _setupNetworkListener();
    });
  }

  void _setupNetworkListener() {
    // Listen for network changes - auto-sync when going online
    _networkSub = NetworkService().onStatus.listen((isOnline) {
      Logger().d(
        'OverviewPage: Network status = $isOnline, wasOffline = $_wasOffline',
      );
      if (isOnline && _wasOffline) {
        // Went from offline to online - trigger sync
        _triggerAutoSync();
      }
      _wasOffline = !isOnline;
    });
  }

  void _triggerAutoSync() {
    final dompetState = context.read<DompetBloc>().state;
    if (dompetState is DompetLoaded) {
      Logger().d('OverviewPage: Triggering auto-sync after coming online');
      context.read<SyncBloc>().add(StartSync(dompetState.dompet.id));
    }
  }

  // Helper for staggered animated sections
  Widget _buildAnimatedSection(int index, Widget child) {
    return FadeTransition(
      opacity: _fadeAnims[index],
      child: SlideTransition(position: _slideAnims[index], child: child),
    );
  }

  @override
  void dispose() {
    _networkSub?.cancel();
    _animController.dispose();
    super.dispose();
  }

  void _loadAnalyzeData() {
    final dompetState = context.read<DompetBloc>().state;
    if (dompetState is DompetLoaded) {
      final now = DateTime.now();
      context.read<AnalyzeBloc>().add(
        LoadAnalyzeData(dompetState.dompet.id, now.month, now.year),
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
    return BlocListener<DompetBloc, DompetState>(
      listener: (context, state) {
        // Show dialog when dompet not found (first time user)
        if (state is DompetNotFound && !_dialogShown) {
          _dialogShown = true;
          InitialWalletDialog.show(context, state.userId);
        }
        // Reload analyze data when dompet loads
        if (state is DompetLoaded) {
          _loadAnalyzeData();
        }
      },
      // Listen for transaction success to trigger auto-sync when online
      child: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionSuccess && NetworkService().isOnline) {
            // Auto-sync after create/update/delete when online
            _triggerAutoSync();
          }
        },
        child: BlocListener<SyncBloc, SyncState>(
          listener: (context, state) {
            // Sync status is now handled by the FAB-style indicator in MainScaffold
            // Just log for debugging
            if (state is SyncSuccess) {
              Logger().d('Sync success: ${state.result.message}');
            } else if (state is SyncError) {
              Logger().e('Sync error: ${state.error}');
            } else if (state is SyncInProgress) {
              Logger().d('Sync in progress: ${state.message}');
            }
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome section - animated index 0
                  _buildAnimatedSection(
                    0,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selamat Datang!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          FirebaseAuth.instance.currentUser?.email ?? 'User',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Balance Card
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

                      return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue.shade600,
                              Colors.blue.shade400,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withValues(alpha: 0.3),
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
                                  'Total Saldo',
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
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            // Income and Expense row
                            Row(
                              children: [
                                // Income
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
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
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Pemasukkan',
                                            style: TextStyle(
                                              color: Colors.white60,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            _formatCurrency(pemasukkan),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
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
                                        padding: const EdgeInsets.all(8),
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
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Pengeluaran',
                                            style: TextStyle(
                                              color: Colors.white60,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            _formatCurrency(pengeluaran),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
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
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // AI Quick Actions - Scan & Voice
                  const Text(
                    'Input Cepat AI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildQuickAction(
                        icon: Icons.camera_alt,
                        label: 'Scan Struk',
                        color: Colors.purple,
                        onTap: () async {
                          // Pick image from camera with compression for faster processing
                          final XFile? image = await _imagePicker.pickImage(
                            source: ImageSource.camera,
                            imageQuality: 75, // Compress to 75% quality
                            maxWidth: 1080, // Limit max width to 1080px
                          );
                          if (image != null && mounted) {
                            // Show notification that image is being processed
                            NotificationService().showInfo(
                              'Foto struk berhasil diambil!',
                            );
                            // Switch to transaction branch with image path
                            context.go('/transaction?scanImage=${image.path}');
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildQuickAction(
                        icon: Icons.mic,
                        label: 'Input Suara',
                        color: Colors.orange,
                        onTap: () {
                          // Variable to store voice result
                          ReceiptAnalysisResult? voiceResult;

                          // Show voice recording sheet
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (sheetContext) => VoiceRecordingSheet(
                              voiceDataSource: VoiceRemoteDataSourceImpl(),
                              onResult: (result) {
                                // Just store the result - VoiceRecordingSheet will pop itself
                                voiceResult = result;
                              },
                            ),
                          ).then((_) {
                            // This runs AFTER modal is fully closed
                            if (voiceResult != null && mounted) {
                              NotificationService().showInfo(
                                'Suara berhasil diproses!',
                              );

                              final amount = voiceResult!.amount?.toInt() ?? 0;
                              final desc = Uri.encodeComponent(
                                voiceResult!.description ?? '',
                              );
                              final cat = voiceResult!.category?.name ?? '';

                              // Switch to transaction branch with voice data
                              context.go(
                                '/transaction?voiceAmount=$amount&voiceDesc=$desc&voiceCat=$cat',
                              );
                            }
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  // Quick Actions
                  const Text(
                    'Menu Cepat',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildQuickAction(
                        icon: Icons.add_circle_outline,
                        label: 'Pemasukkan',
                        color: Colors.green,
                        onTap: () {
                          context.go('/transaction?type=pemasukkan');
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildQuickAction(
                        icon: Icons.remove_circle_outline,
                        label: 'Pengeluaran',
                        color: Colors.red,
                        onTap: () {
                          context.go('/transaction?type=pengeluaran');
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildQuickAction(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Anggaran',
                        color: Colors.purple,
                        onTap: () {
                          context.go('/budget');
                        },
                      ),
                      const SizedBox(width: 12),
                      BlocBuilder<SyncBloc, SyncState>(
                        builder: (context, syncState) {
                          final isLoading = syncState is SyncInProgress;
                          return _buildQuickAction(
                            icon: isLoading ? Icons.hourglass_top : Icons.sync,
                            label: 'Sync',
                            color: Colors.cyan,
                            onTap: isLoading
                                ? () {}
                                : () {
                                    final dompetState = context
                                        .read<DompetBloc>()
                                        .state;
                                    if (dompetState is DompetLoaded) {
                                      context.read<SyncBloc>().add(
                                        StartSync(dompetState.dompet.id),
                                      );
                                    }
                                  },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Spending by Category Pie Chart
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF2D3250),
                          const Color(0xFF424769),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pengeluaran per Kategori',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder<DompetBloc, DompetState>(
                          builder: (context, state) {
                            if (state is! DompetLoaded) {
                              return const SizedBox(
                                height: 200,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return _buildCategoryPieChart(state.dompet.id);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Area Chart - Daily Spending Trend
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF1A3A52),
                          const Color(0xFF2E5977),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tren Pengeluaran Bulan Ini',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        BlocBuilder<DompetBloc, DompetState>(
                          builder: (context, state) {
                            if (state is! DompetLoaded) {
                              return const SizedBox(
                                height: 200,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            return _buildSpendingAreaChart(state.dompet.id);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPieChart(int dompetId) {
    return BlocBuilder<AnalyzeBloc, AnalyzeState>(
      builder: (context, state) {
        if (state is AnalyzeLoading) {
          return Container(
            height: 200,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AnalyzeLoaded && state.categorySpending.isNotEmpty) {
          final total = state.categorySpending.values.fold(
            0.0,
            (a, b) => a + b,
          );

          return Container(
            height: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: Row(
              children: [
                // Pie chart
                Expanded(
                  flex: 2,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 30,
                      sections: state.categorySpending.entries.map((entry) {
                        final percentage = (entry.value / total * 100);
                        return PieChartSectionData(
                          value: entry.value,
                          title: '${percentage.toStringAsFixed(0)}%',
                          color: _getCategoryColor(entry.key),
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                // Legend
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: state.categorySpending.entries.take(5).map((
                      entry,
                    ) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _getCategoryColor(entry.key),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                entry.key.label,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }

        // Empty state
        return Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.pie_chart, size: 48, color: Colors.white38),
                SizedBox(height: 8),
                Text(
                  'Belum ada data pengeluaran',
                  style: TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpendingAreaChart(int dompetId) {
    return BlocBuilder<AnalyzeBloc, AnalyzeState>(
      builder: (context, state) {
        if (state is AnalyzeLoading) {
          return Container(
            height: 200,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        // Require minimum 2 days of data to show trend
        if (state is AnalyzeLoaded && state.dailySpending.length >= 2) {
          // Build line chart data
          final sortedDays = state.dailySpending.keys.toList()..sort();
          final maxY = state.dailySpending.values.fold(
            0.0,
            (a, b) => a > b ? a : b,
          );

          return Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white24),
            ),
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value % 5 == 0) {
                          return Text(
                            '${value.toInt()}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white54,
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                // Enable touch tooltip with dragging
                lineTouchData: LineTouchData(
                  enabled: true,
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (spot) => const Color(0xFF2D3250),
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.all(8),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final day = spot.x.toInt();
                        final amount = spot.y;
                        return LineTooltipItem(
                          'Hari $day\n${_formatCurrency(amount)}',
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: sortedDays.map((day) {
                      return FlSpot(
                        day.toDouble(),
                        state.dailySpending[day] ?? 0,
                      );
                    }).toList(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withValues(alpha: 0.2),
                    ),
                    // Show dots on the line
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 2,
                          strokeColor: Colors.blue,
                        );
                      },
                    ),
                  ),
                ],
                minY: 0,
                maxY: maxY * 1.2,
              ),
            ),
          );
        }

        // Empty state
        return Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24),
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.show_chart, size: 48, color: Colors.white38),
                SizedBox(height: 8),
                Text(
                  'Belum ada data harian',
                  style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
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

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
