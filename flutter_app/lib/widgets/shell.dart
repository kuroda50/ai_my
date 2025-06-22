import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Shell extends StatelessWidget {
  final Widget child;

  const Shell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;

    // 現在のタブインデックスを決定
    int currentIndex = 0;
    if (location.startsWith('/home')) {
      currentIndex = 0;
    } else if (location.startsWith('/cafe')) {
      currentIndex = 1;
    } else if (location.startsWith('/library')) {
      currentIndex = 2;
    } else if (location.startsWith('/profile')) {
      currentIndex = 3;
    }
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label:'ホーム'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_cafe_outlined),
            activeIcon: Icon(Icons.local_cafe),
            label: 'カフェ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books_outlined),
            activeIcon: Icon(Icons.library_books),
            label: 'ライブラリ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_off_outlined),
            activeIcon: Icon(Icons.person),
            label: 'プロフィール',
          ),
        ],
      ),
    );
  }

   void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        GoRouter.of(context).go('/home');
        break;
      case 1:
        GoRouter.of(context).go('/cafe');
        break;
      case 2:
        GoRouter.of(context).go('/library');
        break;
      case 3:
        GoRouter.of(context).go('/profile');
        break;
    }
  }
}
