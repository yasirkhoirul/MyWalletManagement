import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:module_core/service/network/network_service.dart';
import 'package:module_core/service/notification/notification_service.dart';
import 'package:module_core/service/transaction_form_notifier.dart';

/// Sync status for display (kept for backwards compatibility)
enum SyncStatus { idle, syncing, success, failed }

class MainScaffold extends StatefulWidget {
  final StatefulNavigationShell navigationShellState;
  final VoidCallback? onLogout;
  final Stream<SyncStatus>? syncStatusStream;

  const MainScaffold(
    this.navigationShellState, {
    this.onLogout,
    this.syncStatusStream,
    super.key,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late final TransactionFormNotifier _formNotifier;

  @override
  void initState() {
    super.initState();
    _formNotifier = GetIt.I<TransactionFormNotifier>();
    // Listen to sync status and forward to notification service
    widget.syncStatusStream?.listen((status) {
      switch (status) {
        case SyncStatus.syncing:
          NotificationService().showSyncing();
          break;
        case SyncStatus.success:
          NotificationService().showSyncSuccess();
          break;
        case SyncStatus.failed:
          NotificationService().showSyncError();
          break;
        case SyncStatus.idle:
          break;
      }
    });
  }

  /// Check if user is on transaction page and has unsaved data before switching tab
  Future<bool> _canLeaveTransaction() async {
    final isOnTransaction = widget.navigationShellState.currentIndex == 1;
    if (!isOnTransaction || !_formNotifier.hasUnsavedChanges) return true;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text(
              'Data Belum Disimpan',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Anda memiliki data transaksi yang belum disimpan. Yakin ingin pindah halaman?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Tetap di Halaman',
              style: TextStyle(color: Colors.amber),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Pindah',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _goToBranch(int index) async {
    if (widget.navigationShellState.currentIndex == index) return;
    final canLeave = await _canLeaveTransaction();
    if (canLeave) {
      widget.navigationShellState.goBranch(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnTransaction = widget.navigationShellState.currentIndex == 1;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: StreamBuilder<bool>(
            stream: NetworkService().onStatus,
            initialData: false,
            builder: (context, snapshot) {
              final online = snapshot.data ?? false;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: online
                          ? Colors.green.withValues(alpha: 0.2)
                          : Colors.red.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      online ? Icons.wifi : Icons.signal_wifi_off,
                      size: 16,
                      color: online ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    online ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: online
                          ? Colors.green.shade300
                          : Colors.red.shade300,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            IconButton(
              tooltip: 'Logout',
              icon: const Icon(Icons.logout, color: Colors.white70),
              onPressed: widget.onLogout,
            ),
          ],
        ),
        floatingActionButton: ListenableBuilder(
          listenable: _formNotifier,
          builder: (context, _) {
            if (isOnTransaction) {
              // Save button on transaction page
              return Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFA726), Color(0xFFFF9800)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: () => _formNotifier.triggerSave(),
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: const Icon(Icons.save, size: 28, color: Colors.white),
                ),
              );
            } else {
              // Add button on other pages
              return Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6C63FF), Color(0xFF4A90E2)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: () {
                    widget.navigationShellState.goBranch(1);
                  },
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: const Icon(Icons.add, size: 28, color: Colors.white),
                ),
              );
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
          height: 87,
          color: const Color(0xFF16213E),
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                isSelected: widget.navigationShellState.currentIndex == 0,
                onTap: () => _goToBranch(0),
              ),
              _buildNavItem(
                icon: Icons.account_balance_wallet_outlined,
                activeIcon: Icons.account_balance_wallet,
                label: 'Riwayat',
                isSelected: widget.navigationShellState.currentIndex == 2,
                onTap: () => _goToBranch(2),
              ),
              const SizedBox(width: 48),
              _buildNavItem(
                icon: Icons.analytics_outlined,
                activeIcon: Icons.analytics,
                label: 'Analisis',
                isSelected: widget.navigationShellState.currentIndex == 3,
                onTap: () => _goToBranch(3),
              ),
              _buildNavItem(
                icon: Icons.build_circle_outlined,
                activeIcon: Icons.build_circle_rounded,
                label: 'Anggaran',
                isSelected: widget.navigationShellState.currentIndex == 4,
                onTap: () => _goToBranch(4),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            SafeArea(child: widget.navigationShellState),
            // Queued notification indicator in bottom left
            Positioned(
              left: 16,
              bottom: 100,
              child: StreamBuilder<ToastMessage?>(
                stream: NotificationService().stream,
                builder: (context, snapshot) {
                  final message = snapshot.data;
                  if (message == null) {
                    return const SizedBox.shrink();
                  }
                  return _ToastWidget(message: message);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected
                  ? const Color(0xFF4A90E2)
                  : Colors.grey.shade500,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xFF4A90E2)
                    : Colors.grey.shade500,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToastWidget extends StatelessWidget {
  final ToastMessage message;

  const _ToastWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 200),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(-20 * (1 - value), 0),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _getBackgroundColor(),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (message.type == ToastType.syncing)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              Icon(_getIcon(), color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              message.message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (message.type) {
      case ToastType.success:
        return Colors.green.shade700;
      case ToastType.error:
        return Colors.red.shade700;
      case ToastType.info:
        return const Color(0xFF2D3250);
      case ToastType.syncing:
        return const Color(0xFF2D3250);
    }
  }

  IconData _getIcon() {
    switch (message.type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.info:
        return Icons.info;
      case ToastType.syncing:
        return Icons.sync;
    }
  }
}
