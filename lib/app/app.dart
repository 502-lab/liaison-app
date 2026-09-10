import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liaison_app/core/config/app_config_provider.dart';

class App extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(appConfigProvider);
    return MaterialApp(
      title: 'Liaison',
      home: Scaffold(
        body: Center(child: Text('flavor: ${config.flavor.name}')),
      ),
    );
  }
}
