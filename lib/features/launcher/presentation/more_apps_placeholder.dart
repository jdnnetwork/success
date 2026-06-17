import 'package:flutter/material.dart';

/// 더 보기 — limited app-add entry (full add/reorder is Phase 2).
class MoreAppsPlaceholder extends StatelessWidget {
  const MoreAppsPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('더 보기')),
      body: const Center(
        child: Text('더 많은 앱을 곧 추가할 수 있어요',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
