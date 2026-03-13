import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class EncryptedNotesScreen extends StatefulWidget {
  const EncryptedNotesScreen({super.key});
  @override State<EncryptedNotesScreen> createState() => _EncryptedNotesScreenState();
}

class _EncryptedNotesScreenState extends State<EncryptedNotesScreen> {
  final _storage = const FlutterSecureStorage();
  List<Map<String, dynamic>> _notes = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final data = await _storage.read(key: 'encrypted_notes');
      if (data != null) {
        final list = jsonDecode(data) as List;
        setState(() => _notes = list.map((e) => Map<String, dynamic>.from(e)).toList());
      }
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    await _storage.write(key: 'encrypted_notes', value: jsonEncode(_notes));
  }

  void _addOrEdit({Map<String, dynamic>? existing, int? index}) {
    final titleCtrl = TextEditingController(text: existing?['title'] ?? '');
    final bodyCtrl = TextEditingController(text: existing?['body'] ?? '');
    String selectedTag = existing?['tag'] ?? 'genel';

    final tags = ['genel', 'şifre', 'not', 'önemli', 'gizli'];
    final tagColors = {'genel': Colors.blue, 'şifre': Colors.green, 'not': Colors.orange, 'önemli': Colors.red, 'gizli': Colors.purple};

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => StatefulBuilder(
        builder: (context, setS) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lock, color: Theme.of(context).colorScheme.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(existing != null ? 'NOTU DÜZENLE' : 'YENİ ŞİFRELİ NOT',
                      style: GoogleFonts.orbitron(color: Theme.of(context).colorScheme.primary, fontSize: 13, letterSpacing: 2)),
                ],
              ),
              const SizedBox(height: 16),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Başlık')),
              const SizedBox(height: 12),
              TextField(controller: bodyCtrl, maxLines: 5, decoration: const InputDecoration(labelText: 'İçerik', alignLabelWithHint: true)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: tags.map((t) => GestureDetector(
                  onTap: () => setS(() => selectedTag = t),
                  child: Chip(
                    label: Text(t, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: selectedTag == t ? Colors.black : Colors.white60)),
                    backgroundColor: selectedTag == t ? (tagColors[t] ?? Colors.blue) : Colors.white10,
                    side: BorderSide.none,
                  ),
                )).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: ElevatedButton(
                    onPressed: () {
                      if (titleCtrl.text.isNotEmpty) {
                        final note = {'title': titleCtrl.text, 'body': bodyCtrl.text, 'tag': selectedTag, 'date': DateTime.now().toIso8601String()};
                        setState(() {
                          if (existing != null && index != null) _notes[index] = note;
                          else _notes.insert(0, note);
                        });
                        _save();
                        Navigator.pop(context);
                      }
                    },
                    child: Text(existing != null ? 'GÜNCELLE' : 'KAYDET'),
                  )),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final tagColors = {'genel': Colors.blue, 'şifre': Colors.green, 'not': Colors.orange, 'önemli': Colors.red, 'gizli': Colors.purple};

    return Scaffold(
      appBar: AppBar(title: const Text('ŞİFRELİ NOTLAR')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEdit(),
        backgroundColor: primary,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: primary))
          : _notes.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.note_add_outlined, size: 64, color: primary.withOpacity(0.2)),
                  const SizedBox(height: 16),
                  Text('Henüz şifreli not yok', style: GoogleFonts.jetBrainsMono(color: Colors.white30)),
                ]))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notes.length,
                  itemBuilder: (context, i) {
                    final note = _notes[i];
                    final tagColor = tagColors[note['tag']] ?? Colors.blue;
                    final date = DateTime.tryParse(note['date'] ?? '');

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _addOrEdit(existing: note, index: i),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Icon(Icons.lock, color: tagColor, size: 16),
                              const SizedBox(width: 8),
                              Expanded(child: Text(note['title'] ?? '', style: GoogleFonts.orbitron(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700))),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(color: tagColor.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                                child: Text(note['tag'] ?? '', style: GoogleFonts.jetBrainsMono(color: tagColor, fontSize: 10)),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                onPressed: () { setState(() => _notes.removeAt(i)); _save(); },
                                padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                              ),
                            ]),
                            if ((note['body'] ?? '').isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                note['body'],
                                maxLines: 3, overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.jetBrainsMono(color: Colors.white54, fontSize: 12),
                              ),
                            ],
                            if (date != null) ...[
                              const SizedBox(height: 8),
                              Text('${date.day}.${date.month}.${date.year}', style: GoogleFonts.jetBrainsMono(color: Colors.white24, fontSize: 10)),
                            ],
                          ]),
                        ),
                      ),
                    ).animate(delay: Duration(milliseconds: i * 80)).fadeIn().slideX(begin: 0.2);
                  },
                ),
    );
  }
}
