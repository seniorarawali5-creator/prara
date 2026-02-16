import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  String _filterType = 'all'; // all, public, private

  final List<Map<String, dynamic>> notes = [
    {
      'id': '1',
      'title': 'Flutter Widgets Guide',
      'content': 'MaterialApp, Scaffold, AppBar, FloatingActionButton, TextField...',
      'visibility': 'public',
      'author': 'You',
      'createdAt': '2 days ago',
      'attachments': 0,
    },
    {
      'id': '2',
      'title': 'Quantum Physics Notes',
      'content': 'Wave-particle duality, Schrödinger\'s equation, probability density...',
      'visibility': 'private',
      'author': 'You',
      'createdAt': '1 day ago',
      'attachments': 2,
    },
    {
      'id': '3',
      'title': 'React Hooks Deep Dive',
      'content': 'useState, useEffect, useContext, useReducer, custom hooks...',
      'visibility': 'public',
      'author': 'Priya Sharma',
      'createdAt': '3 hours ago',
      'attachments': 1,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredNotes = _filterType == 'all'
        ? notes
        : notes.where((n) => n['visibility'] == _filterType).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: PopupMenuButton<String>(
                onSelected: (value) => setState(() => _filterType = value),
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem(value: 'all', child: Text('All Notes')),
                  const PopupMenuItem(value: 'public', child: Text('Public')),
                  const PopupMenuItem(value: 'private', child: Text('Private')),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Filter', style: TextStyle(color: Color(0xFF6366F1))),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, color: Color(0xFF6366F1)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: filteredNotes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.note_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No notes found',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                final note = filteredNotes[index];
                return GestureDetector(
                  onTap: () => Get.toNamed('/note_detail', arguments: note),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                        ),
                      ],
                      border: Border.all(
                        color: note['visibility'] == 'public'
                            ? const Color(0xFF10B981).withOpacity(0.3)
                            : const Color(0xFFF59E0B).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                note['title'],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: note['visibility'] == 'public'
                                    ? const Color(0xFF10B981).withOpacity(0.1)
                                    : const Color(0xFFF59E0B).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                note['visibility'][0].toUpperCase() +
                                    note['visibility'].substring(1),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: note['visibility'] == 'public'
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFF59E0B),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          note['content'],
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'By ${note['author']}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  note['createdAt'],
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            if (note['attachments'] > 0)
                              Row(
                                children: [
                                  Icon(
                                    Icons.attachment,
                                    size: 14,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${note['attachments']}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6366F1),
        onPressed: () => Get.toNamed('/create_note'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
