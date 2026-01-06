import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/web.dart';
import 'package:module_core/service/network/network_service.dart';
// removed service_locator; use NetworkService singleton directly

class MainScaffold extends StatelessWidget{
  final StatefulNavigationShell navigationShellState;
  final VoidCallback? onLogout;
  const MainScaffold(this.navigationShellState, {this.onLogout, super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // show network indicator in the leading area of AppBar
        title: StreamBuilder<bool>(
          stream: NetworkService().onStatus,
          initialData: false,
          builder: (context, snapshot) {
            Logger().d("ini terjadi perubahan ${snapshot.data}");
            final online = snapshot.data ?? false;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  online ? Icons.wifi : Icons.signal_wifi_off,
                  size: 20,
                  color: online ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 6),
                Text(
                  online ? 'Online' : 'Offline',
                  style: TextStyle(
                    color: online ? Colors.green.shade50 : Colors.red.shade50,
                    fontSize: 12,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: onLogout,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShellState.currentIndex,
        onTap: (index){
          navigationShellState.goBranch(index);
        },
        backgroundColor: Theme.of(context).colorScheme.secondary,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.primary.withOpacity(0.7),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      body: navigationShellState,
    );
  }

}