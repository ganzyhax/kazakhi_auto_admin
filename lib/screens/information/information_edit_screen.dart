import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:kazakhi_auto_admin/constants/app_colors.dart';

// The rest of the existing classes and enums can remain the same
// BlockType, BlockTypeX, ContentBlock, PickedFileItem

enum BlockType { description, title, images, files, urls }

extension BlockTypeX on BlockType {
  String get label => switch (this) {
    BlockType.description => 'Описание',
    BlockType.title => 'Заголовок',
    BlockType.images => 'Изображения',
    BlockType.files => 'Файлы',
    BlockType.urls => 'Ссылки',
  };
}

class ContentBlock {
  final String id;
  final BlockType type;
  TextEditingController? descriptionCtrl; // for description and h2Title
  List<PickedFileItem> images; // local files first; uploadedUrl after save
  List<PickedFileItem> files; // local files first; uploadedUrl after save
  List<TextEditingController> urls; // list of link strings

  ContentBlock.description()
    : id = UniqueKey().toString(),
      type = BlockType.description,
      descriptionCtrl = TextEditingController(),
      images = const [],
      files = const [],
      urls = const [];

  ContentBlock.h2Title()
    : id = UniqueKey().toString(),
      type = BlockType.title,
      descriptionCtrl = TextEditingController(),
      images = const [],
      files = const [],
      urls = const [];

  ContentBlock.imagesBlock()
    : id = UniqueKey().toString(),
      type = BlockType.images,
      descriptionCtrl = null,
      images = <PickedFileItem>[],
      files = const [],
      urls = const [];

  ContentBlock.filesBlock()
    : id = UniqueKey().toString(),
      type = BlockType.files,
      descriptionCtrl = null,
      images = const [],
      files = <PickedFileItem>[],
      urls = const [];

  ContentBlock.urlsBlock()
    : id = UniqueKey().toString(),
      type = BlockType.urls,
      descriptionCtrl = null,
      images = const [],
      files = const [],
      urls = <TextEditingController>[];

  factory ContentBlock.fromMap(Map<String, dynamic> map) {
    final type = map['type'] as String;
    switch (type) {
      case 'description':
        return ContentBlock.description()
          ..descriptionCtrl!.text = map['value'] as String;
      case 'title':
        return ContentBlock.h2Title()
          ..descriptionCtrl!.text = map['value'] as String;
      case 'image':
        return ContentBlock.imagesBlock()
          ..images.add(PickedFileItem.fromUrl(map['value'] as String));
      case 'file':
        return ContentBlock.filesBlock()
          ..files.add(PickedFileItem.fromUrl(map['value'] as String));
      case 'url':
        return ContentBlock.urlsBlock()
          ..urls.add(TextEditingController()..text = map['value'] as String);
      default:
        throw Exception('Unknown block type: $type');
    }
  }
}

class PickedFileItem {
  PlatformFile? file; // must contain bytes (withData:true)
  String uniqueId;
  String? uploadedUrl; // set after save

  PickedFileItem({required PlatformFile file})
    : uniqueId =
          '${DateTime.now().microsecondsSinceEpoch}_${file.name}_${file.size}',
      file = file,
      uploadedUrl = null;

  PickedFileItem.fromUrl(String url)
    : uniqueId = url, // Use URL as unique ID for consistency
      file = null,
      uploadedUrl = url;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PickedFileItem &&
          runtimeType == other.runtimeType &&
          uniqueId == other.uniqueId;

  @override
  int get hashCode => uniqueId.hashCode;
}

class CreateBlockPage extends StatefulWidget {
  final String? contentId;

  const CreateBlockPage({super.key, this.contentId});

  @override
  State<CreateBlockPage> createState() => _CreateBlockPageState();
}

class _CreateBlockPageState extends State<CreateBlockPage> {
  final List<ContentBlock> blocks = [];
  bool saving = false;
  bool loading = false;

  static const String uploadEndpoint =
      'https://back.kazakhiauto.kz/api/admin/uploadFile';
  static const String saveEndpoint =
      'https://back.kazakhiauto.kz/api/dropcontent';
  static const String fetchEndpoint =
      'https://back.kazakhiauto.kz/api/dropcontent';

  bool get isNew => widget.contentId == null;

  @override
  void initState() {
    super.initState();
    if (!isNew) {
      _fetchContent();
    }
  }

  @override
  void dispose() {
    for (final b in blocks) {
      b.descriptionCtrl?.dispose();
      for (final c in b.urls) c.dispose();
    }
    super.dispose();
  }

  Future<void> _fetchContent() async {
    setState(() => loading = true);
    try {
      final res = await http.get(
        Uri.parse('$fetchEndpoint/${widget.contentId}'),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final content = data['content'] as List;

        // Group blocks of the same type
        final groupedBlocks = <BlockType, List<Map<String, dynamic>>>{};
        for (final item in content) {
          final type = item['type'] as String;
          final blockType = BlockType.values.firstWhere(
            (e) => e.toString().contains(type),
          );
          groupedBlocks.putIfAbsent(blockType, () => []).add(item);
        }

        final newBlocks = <ContentBlock>[];
        groupedBlocks.forEach((type, items) {
          if (type == BlockType.images) {
            final block = ContentBlock.imagesBlock();
            block.images.addAll(
              items.map((e) => PickedFileItem.fromUrl(e['value'] as String)),
            );
            newBlocks.add(block);
          } else if (type == BlockType.files) {
            final block = ContentBlock.filesBlock();
            block.files.addAll(
              items.map((e) => PickedFileItem.fromUrl(e['value'] as String)),
            );
            newBlocks.add(block);
          } else if (type == BlockType.urls) {
            final block = ContentBlock.urlsBlock();
            block.urls.addAll(
              items.map(
                (e) => TextEditingController(text: e['value'] as String),
              ),
            );
            newBlocks.add(block);
          } else {
            // For description and title, add each item as a separate block
            for (final item in items) {
              final block = ContentBlock.fromMap(item);
              newBlocks.add(block);
            }
          }
        });
        setState(() => blocks.addAll(newBlocks));
      } else {
        _showMsg(
          'Не удалось загрузить контент: ${res.statusCode} - ${res.body}',
          error: true,
        );
      }
    } catch (e) {
      _showMsg('Ошибка сети при загрузке контента: $e', error: true);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<String?> _uploadToServer(PlatformFile file) async {
    if (file.bytes == null) {
      _showMsg(
        'У файла нет байтов. Убедитесь, что withData:true.',
        error: true,
      );
      return null;
    }
    try {
      final req = http.MultipartRequest('POST', Uri.parse(uploadEndpoint));
      req.files.add(
        http.MultipartFile.fromBytes('file', file.bytes!, filename: file.name),
      );
      final res = await req.send();
      final body = await res.stream.bytesToString();
      if (res.statusCode == 200) {
        final data = jsonDecode(body) as Map<String, dynamic>;
        return data['url'] as String?;
      }
      _showMsg('Ошибка загрузки: ${res.statusCode} — $body', error: true);
      return null;
    } catch (e) {
      _showMsg('Ошибка загрузки: $e', error: true);
      return null;
    }
  }

  void _showMsg(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: error ? Colors.red : null),
    );
  }

  void _addBlock(BlockType type) {
    setState(() {
      switch (type) {
        case BlockType.description:
          blocks.add(ContentBlock.description());
          break;
        case BlockType.title:
          blocks.add(ContentBlock.h2Title());
          break;
        case BlockType.images:
          blocks.add(ContentBlock.imagesBlock());
          break;
        case BlockType.files:
          blocks.add(ContentBlock.filesBlock());
          break;
        case BlockType.urls:
          blocks.add(ContentBlock.urlsBlock());
          break;
      }
    });
  }

  Future<void> _pickImages(ContentBlock b) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result == null) return;
    setState(
      () => b.images.addAll(result.files.map((f) => PickedFileItem(file: f))),
    );
  }

  Future<void> _pickFiles(ContentBlock b) async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
    );
    if (result == null) return;
    setState(
      () => b.files.addAll(result.files.map((f) => PickedFileItem(file: f))),
    );
  }

  Future<void> _save() async {
    setState(() => saving = true);

    for (final b in blocks) {
      if (b.type == BlockType.images) {
        for (final img in b.images) {
          if (img.uploadedUrl == null && img.file != null) {
            final url = await _uploadToServer(img.file!);
            if (url != null) img.uploadedUrl = url;
          }
        }
      }
      if (b.type == BlockType.files) {
        for (final f in b.files) {
          if (f.uploadedUrl == null && f.file != null) {
            final url = await _uploadToServer(f.file!);
            if (url != null) f.uploadedUrl = url;
          }
        }
      }
    }

    final content = <Map<String, dynamic>>[];
    for (final b in blocks) {
      switch (b.type) {
        case BlockType.description:
          final value = b.descriptionCtrl!.text.trim();
          if (value.isNotEmpty) {
            content.add({'type': 'description', 'value': value});
          }
          break;
        case BlockType.title:
          final value = b.descriptionCtrl!.text.trim();
          if (value.isNotEmpty) {
            content.add({'type': 'title', 'value': value});
          }
          break;
        case BlockType.images:
          for (final img in b.images) {
            if (img.uploadedUrl != null) {
              content.add({'type': 'image', 'value': img.uploadedUrl});
            }
          }
          break;
        case BlockType.files:
          for (final f in b.files) {
            if (f.uploadedUrl != null) {
              content.add({'type': 'file', 'value': f.uploadedUrl});
            }
          }
          break;
        case BlockType.urls:
          for (final c in b.urls) {
            final v = c.text.trim();
            if (v.isNotEmpty) content.add({'type': 'url', 'value': v});
          }
          break;
      }
    }

    final payload = {'content': content};
    final uri =
        isNew
            ? Uri.parse(saveEndpoint)
            : Uri.parse('$saveEndpoint/${widget.contentId}');

    try {
      final res = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        _showMsg('Сохранено ✓');
        if (isNew) {}
      } else {
        _showMsg(
          'Ошибка сохранения: ${res.statusCode} — ${res.body}',
          error: true,
        );
      }
    } catch (e) {
      _showMsg('Ошибка сети: $e', error: true);
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          isNew ? 'Админ — Новый контент' : 'Админ — Редактировать контент',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Center(child: Text('Блоки: ${blocks.length}')),
          ),
        ],
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      'Блоки',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    Wrap(
                                      spacing: 8,
                                      children: [
                                        OutlinedButton.icon(
                                          onPressed:
                                              () => _addBlock(
                                                BlockType.description,
                                              ),
                                          icon: const Icon(Icons.notes),
                                          label: const Text(
                                            'Добавить описание',
                                          ),
                                        ),
                                        OutlinedButton.icon(
                                          onPressed:
                                              () => _addBlock(BlockType.title),
                                          icon: const Icon(Icons.title),
                                          label: const Text(
                                            'Добавить заголовок',
                                          ),
                                        ),
                                        OutlinedButton.icon(
                                          onPressed:
                                              () => _addBlock(BlockType.images),
                                          icon: const Icon(Icons.photo_library),
                                          label: const Text(
                                            'Добавить изображения',
                                          ),
                                        ),
                                        OutlinedButton.icon(
                                          onPressed:
                                              () => _addBlock(BlockType.files),
                                          icon: const Icon(
                                            Icons.picture_as_pdf,
                                          ),
                                          label: const Text('Добавить файлы'),
                                        ),
                                        OutlinedButton.icon(
                                          onPressed:
                                              () => _addBlock(BlockType.urls),
                                          icon: const Icon(Icons.link),
                                          label: const Text('Добавить ссылки'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                blocks.isEmpty
                                    ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Text(
                                        'Пока нет блоков. Используйте кнопки выше, чтобы добавить.',
                                      ),
                                    )
                                    : ReorderableListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: blocks.length,
                                      onReorder: (oldIndex, newIndex) {
                                        setState(() {
                                          if (newIndex > oldIndex) newIndex--;
                                          final item = blocks.removeAt(
                                            oldIndex,
                                          );
                                          blocks.insert(newIndex, item);
                                        });
                                      },
                                      itemBuilder:
                                          (context, i) =>
                                              _buildBlockTile(blocks[i], i),
                                    ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: saving ? null : _save,
                            icon:
                                saving
                                    ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Icon(Icons.save),
                            label: const Text('Сохранить'),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Container(
                    width: 360,
                    height: double.infinity,
                    color: Colors.grey.shade100,
                    child: ListView(
                      padding: const EdgeInsets.all(12),
                      children: [
                        for (final b in blocks) ..._buildPreviewForBlock(b),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildBlockTile(ContentBlock b, int index) {
    return Card(
      color: AppColors.background,
      key: ValueKey(b.id),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ReorderableDragStartListener(
                  index: index,
                  child: const Icon(Icons.drag_indicator),
                ),
                const SizedBox(width: 8),
                Text(
                  b.type.label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Удалить',
                  onPressed: () => setState(() => blocks.removeAt(index)),
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            switch (b.type) {
              BlockType.description || BlockType.title => TextField(
                controller: b.descriptionCtrl,
                minLines: b.type == BlockType.description ? 3 : 1,
                maxLines: b.type == BlockType.description ? 6 : 1,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  hintText:
                      b.type == BlockType.description
                          ? 'Введите описание...'
                          : 'Введите заголовок...',
                ),
                onChanged: (_) => setState(() {}),
              ),
              BlockType.images => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: () => _pickImages(b),
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Добавить изображения'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (b.images.isEmpty) const Text('Нет изображений'),
                  if (b.images.isNotEmpty)
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: b.images.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex--;
                          final item = b.images.removeAt(oldIndex);
                          b.images.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, i) {
                        final it = b.images[i];
                        return ListTile(
                          key: ValueKey(it.uniqueId),
                          leading: Container(
                            width: 56,
                            height: 56,
                            color: Colors.black12,
                            alignment: Alignment.center,
                            child:
                                it.uploadedUrl != null
                                    ? Image.network(
                                      it.uploadedUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (c, o, s) => const Icon(Icons.error),
                                    )
                                    : (it.file?.bytes != null
                                        ? Image.memory(
                                          it.file!.bytes!,
                                          fit: BoxFit.cover,
                                        )
                                        : const Icon(
                                          Icons.image_not_supported,
                                        )),
                          ),
                          title: Text(
                            it.file?.name ??
                                it.uploadedUrl?.split('/').last ??
                                'Неизвестно',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(it.uploadedUrl ?? 'не загружено'),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed:
                                () => setState(() => b.images.removeAt(i)),
                          ),
                        );
                      },
                    ),
                ],
              ),
              BlockType.files => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.icon(
                        onPressed: () => _pickFiles(b),
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Добавить файлы'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (b.files.isEmpty) const Text('Нет файлов'),
                  if (b.files.isNotEmpty)
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: b.files.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex--;
                          final item = b.files.removeAt(oldIndex);
                          b.files.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (context, i) {
                        final it = b.files[i];
                        return ListTile(
                          key: ValueKey(it.uniqueId),
                          leading: const Icon(Icons.insert_drive_file),
                          title: Text(
                            it.file?.name ??
                                it.uploadedUrl?.split('/').last ??
                                'Неизвестно',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(it.uploadedUrl ?? 'не загружено'),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed:
                                () => setState(() => b.files.removeAt(i)),
                          ),
                        );
                      },
                    ),
                ],
              ),
              BlockType.urls => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FilledButton.icon(
                    onPressed:
                        () => setState(
                          () => b.urls.add(TextEditingController()..text = ''),
                        ),
                    icon: const Icon(Icons.add_link),
                    label: const Text('Добавить ссылку'),
                  ),
                  const SizedBox(height: 8),
                  if (b.urls.isEmpty) const Text('Нет ссылок'),
                  for (int i = 0; i < b.urls.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: b.urls[i],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'https://...',
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => setState(() => b.urls.removeAt(i)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            },
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPreviewForBlock(ContentBlock b) {
    switch (b.type) {
      case BlockType.description:
        final text = b.descriptionCtrl!.text.trim();
        if (text.isEmpty) return [];
        return [
          Container(
            width: 360,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(text),
          ),
        ];
      case BlockType.title:
        final text = b.descriptionCtrl!.text.trim();
        if (text.isEmpty) return [];
        return [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ];
      case BlockType.images:
        if (b.images.isEmpty) return [];
        return [
          Container(
            width: 360,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Изображения',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                for (final it in b.images)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          it.uploadedUrl != null
                              ? Image.network(
                                it.uploadedUrl!,
                                width: 336,
                                height: 180,
                                fit: BoxFit.cover,
                              )
                              : (it.file?.bytes != null
                                  ? Image.memory(
                                    it.file!.bytes!,
                                    width: 336,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  )
                                  : const SizedBox(
                                    height: 180,
                                    child: Center(
                                      child: Text('нет предпросмотра'),
                                    ),
                                  )),
                    ),
                  ),
              ],
            ),
          ),
        ];
      case BlockType.files:
        if (b.files.isEmpty) return [];
        return [
          Container(
            width: 360,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Файлы',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                for (final it in b.files)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(
                      it.file?.name ??
                          it.uploadedUrl?.split('/').last ??
                          'Неизвестно',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(it.uploadedUrl ?? 'не загружено'),
                  ),
              ],
            ),
          ),
        ];
      case BlockType.urls:
        final validUrls = b.urls.where((c) => c.text.isNotEmpty).toList();
        if (validUrls.isEmpty) return [];
        return [
          Container(
            width: 360,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ссылки',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                for (final c in validUrls)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '• ${c.text}',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ),
              ],
            ),
          ),
        ];
    }
  }
}
