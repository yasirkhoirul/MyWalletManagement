import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget{
  final StatefulNavigationShell navigationShellState;
  final VoidCallback? onLogout;
  const MainScaffold(this.navigationShellState, {this.onLogout, super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          tooltip: 'Logout',
          icon: const Icon(Icons.logout),
          onPressed: onLogout,
        ),
      ],),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: navigationShellState.currentIndex,
        onTap: (index){
          navigationShellState.goBranch(index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      body: navigationShellState,
    );
  }

}