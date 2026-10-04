import 'package:flutter/material.dart';
import '../main.dart';
import '../models/essay.dart';

class EditorScreen extends StatefulWidget {
  final Essay essay;
  final ValueChanged<Essay> onChanged;

  const EditorScreen({
    super.key,
    required this.essay,
    required this.onChanged,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late final TextEditingController title;
  late final TextEditingController content;
  double fontSize = 17;

  @override
  void initState() {
    super.initState();
    title = TextEditingController(text: widget.essay.title);
    content = TextEditingController(text: widget.essay.content);
  }

  @override
  void dispose() {
    title.dispose();
    content.dispose();
    super.dispose();
  }

  void save() {
    widget.essay.title = title.text.trim().isEmpty ? 'Untitled essay' : title.text.trim();
    widget.essay.content = content.text;
    widget.essay.updatedAt = DateTime.now();
    widget.onChanged(widget.essay);
  }

  @override
  Widget build(BuildContext context) {
    final words = content.text.trim().isEmpty
        ? 0
        : content.text.trim().split(RegExp(r'\s+')).length;

    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Editor', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(onPressed: save, icon: const Icon(Icons.check_rounded)),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text('$words words',
                    style: const TextStyle(color: kMuted, fontSize: 12)),
                const Spacer(),
                IconButton(
                  tooltip: 'Decrease text size',
                  onPressed: () => setState(() => fontSize = (fontSize - 1).clamp(12, 28).toDouble()),
                  icon: const Icon(Icons.text_decrease_rounded),
                ),
                Text('${fontSize.round()}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                IconButton(
                  tooltip: 'Increase text size',
                  onPressed: () => setState(() => fontSize = (fontSize + 1).clamp(12, 28).toDouble()),
                  icon: const Icon(Icons.text_increase_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
              children: [
                TextField(
                  controller: title,
                  onChanged: (_) => save(),
                  style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w800),
                  decoration: const InputDecoration(
                    hintText: 'Essay title',
                    filled: false,
                    border: InputBorder.none,
                  ),
                ),
                const Divider(height: 1),
                TextField(
                  controller: content,
                  onChanged: (_) => save(),
                  maxLines: null,
                  minLines: 18,
                  style: TextStyle(
                    fontSize: fontSize,
                    height: 1.65,
                    color: kInk,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Start writing your essay...',
                    filled: false,
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
