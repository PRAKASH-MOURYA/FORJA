import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectHealthNudgeCard extends ConsumerWidget {
  final VoidCallback onDismiss;
  const ConnectHealthNudgeCard({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          const Icon(Icons.favorite_border, color: Colors.redAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('Connect Health', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('Auto-import sleep & HR for a smarter readiness score.', style: TextStyle(fontSize: 12)),
            ]),
          ),
          IconButton(icon: const Icon(Icons.close, size: 16), onPressed: onDismiss),
        ]),
      ),
    );
  }
}
