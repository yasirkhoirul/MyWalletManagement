import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:module_core/service/network/network_service.dart';

/// Sync status for display
enum SyncStatus { idle, syncing, success, failed }

class MainScaffold extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
              onPressed: onLogout,
            ),
          ],
        ),
        floatingActionButton: Container(
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
              navigationShellState.goBranch(1);
            },
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: const Icon(Icons.add, size: 28, color: Colors.white),
          ),
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
                isSelected: navigationShellState.currentIndex == 0,
                onTap: () => navigationShellState.goBranch(0),
              ),
              _buildNavItem(
                icon: Icons.account_balance_wallet_outlined,
                activeIcon: Icons.account_balance_wallet,
                label: 'Riwayat',
                isSelected: navigationShellState.currentIndex == 2,
                onTap: () => navigationShellState.goBranch(2),
              ),
              const SizedBox(width: 48),
              _buildNavItem(
                icon: Icons.analytics_outlined,
                activeIcon: Icons.analytics,
                label: 'Analisis',
                isSelected: navigationShellState.currentIndex == 3,
                onTap: () => navigationShellState.goBranch(3),
              ),
              _buildNavItem(
                icon: Icons.build_circle_outlined,
                activeIcon: Icons.build_circle_rounded,
                label: 'Anggaran',
                isSelected: navigationShellState.currentIndex == 4,
                onTap: () => navigationShellState.goBranch(4),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            SafeArea(child: navigationShellState),
            // Sync indicator in bottom left
            if (syncStatusStream != null)
              Positioned(
                left: 16,
                bottom: 100,
                child: StreamBuilder<SyncStatus>(
                  stream: syncStatusStream,
                  initialData: SyncStatus.idle,
                  builder: (context, snapshot) {
                    final status = snapshot.data ?? SyncStatus.idle;
                    return _SyncIndicatorWidget(status: status);
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

class _SyncIndicatorWidget extends StatefulWidget {
  final SyncStatus status;
  const _SyncIndicatorWidget({required this.status});

  @override
  State<_SyncIndicatorWidget> createState() => _SyncIndicatorWidgetState();
}

class _SyncIndicatorWidgetState extends State<_SyncIndicatorWidget> {
  double _opacity = 1.0;

  @override
  void didUpdateWidget(covariant _SyncIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status == SyncStatus.success &&
        oldWidget.status != SyncStatus.success) {
      // Start fade out after success
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _opacity = 0.0);
      });
    } else if (widget.status == SyncStatus.syncing) {
      _opacity = 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.status == SyncStatus.idle) {
      return const SizedBox.shrink();
    }

    return AnimatedOpacity(
      opacity: widget.status == SyncStatus.success ? _opacity : 1.0,
      duration: const Duration(milliseconds: 500),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: widget.status == SyncStatus.syncing
              ? const Color(0xFF2D3250)
              : widget.status == SyncStatus.success
              ? Colors.green.shade700
              : Colors.red.shade700,
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
            if (widget.status == SyncStatus.syncing)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              Icon(
                widget.status == SyncStatus.success
                    ? Icons.check_circle
                    : Icons.error,
                color: Colors.white,
                size: 18,
              ),
            const SizedBox(width: 8),
            Text(
              widget.status == SyncStatus.syncing
                  ? 'Syncing...'
                  : widget.status == SyncStatus.success
                  ? 'Synced!'
                  : 'Sync Failed',
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
}
