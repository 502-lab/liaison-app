import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liaison_app/core/error/app_exception.dart';
import 'package:liaison_app/features/example/domain/model/example_item.dart';
import 'package:liaison_app/features/example/presentation/example_list_provider.dart';

/// 레퍼런스 화면. 스타일은 입히지 않는다.
/// 로딩 · 에러 · 빈 목록 · 목록 네 가지 상태를 모두 다룬다.
class ExampleScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(exampleListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: switch (items) {
        AsyncData(:final value) => _ItemList(items: value),
        AsyncError(:final error) => _ErrorView(
          error: error,
          onRetry: () => ref.read(exampleListProvider.notifier).refresh(),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _ItemList extends StatelessWidget {
  const new({required this.items});

  final List<ExampleItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('항목이 없습니다'));
    }
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) =>
          ListTile(title: Text(items[index].title)),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const new({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final message = switch (error) {
      AppException(:final message) => message,
      _ => '알 수 없는 오류가 발생했습니다',
    };
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          const SizedBox(height: 8),
          FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}
