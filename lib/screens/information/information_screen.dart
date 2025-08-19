import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kazakhi_auto_admin/screens/information/information_edit_screen.dart';

class ContentListPage extends StatefulWidget {
  const ContentListPage({super.key});

  @override
  State<ContentListPage> createState() => _ContentListPageState();
}

class _ContentListPageState extends State<ContentListPage> {
  List<dynamic> contentList = [];
  bool isLoading = false;
  static const String apiEndpoint =
      'https://back.kazakhiauto.kz/api/dropcontent';

  @override
  void initState() {
    super.initState();
    _fetchContentList();
  }

  Future<void> _fetchContentList() async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse(apiEndpoint));
      if (res.statusCode == 200) {
        final List<dynamic> fetchedList = jsonDecode(res.body);

        setState(() => contentList = fetchedList);
      } else {
        _showMsg(
          'Не удалось загрузить список контента: ${res.statusCode}',
          error: true,
        );
      }
    } catch (e) {
      _showMsg('Ошибка сети: $e', error: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _deleteContent(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Подтвердить удаление'),
            content: const Text('Вы уверены, что хотите удалить этот контент?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Удалить'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => isLoading = true);
    try {
      final res = await http.delete(Uri.parse('$apiEndpoint/$id'));
      if (res.statusCode == 200) {
        _showMsg('Контент успешно удален.');
        _fetchContentList();
      } else {
        _showMsg('Не удалось удалить контент: ${res.statusCode}', error: true);
      }
    } catch (e) {
      _showMsg('Ошибка сети: $e', error: true);
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showMsg(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? Colors.red : null),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Список контента'),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _fetchContentList,
            icon: const Icon(Icons.refresh),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              const CreateBlockPage(), // Navigate to create new content
                    ),
                  )
                  .then((_) => _fetchContentList());
            },
            icon: const Icon(Icons.add),
            label: const Text('Создать новый'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: contentList.length,
                itemBuilder: (context, index) {
                  final item = contentList[index];
                  return ListTile(
                    title: Text(item['content'][0]['value'] ?? 'Без названия'),
                    subtitle: Text('Блоков: ${item['content']?.length ?? 0}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder:
                                        (_) => CreateBlockPage(
                                          contentId: item['_id'],
                                        ),
                                  ),
                                )
                                .then((_) => _fetchContentList());
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteContent(item['_id']),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
