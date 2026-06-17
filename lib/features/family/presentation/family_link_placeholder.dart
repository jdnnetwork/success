import 'package:flutter/material.dart';

/// Senior-side family connection entry point (full flow is Phase 5).
class FamilyLinkPlaceholder extends StatelessWidget {
  const FamilyLinkPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('가족 연결')),
      body: const Center(
        child: Text(
          '가족 연결은 곧 준비됩니다',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
