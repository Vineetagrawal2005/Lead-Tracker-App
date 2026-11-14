import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/note_model.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({super.key, required this.note, required this.onDelete});

  final NoteModel note;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, h:mm a');
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(note.text),
        subtitle: Text(
          dateFormat.format(note.createdAt),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: 'Delete note',
          onPressed: onDelete,
        ),
      ),
    );
  }
}
