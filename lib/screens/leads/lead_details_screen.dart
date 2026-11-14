import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/launcher_helper.dart';
import '../../core/theme.dart';
import '../../core/validators.dart';
import '../../models/lead_model.dart';
import '../../providers/lead_provider.dart';
import '../../widgets/note_tile.dart';
import '../../widgets/status_chip.dart';

class LeadDetailsScreen extends StatefulWidget {
  const LeadDetailsScreen({super.key, required this.leadId, this.heroTag});

  final String leadId;
  final String? heroTag;

  @override
  State<LeadDetailsScreen> createState() => _LeadDetailsScreenState();
}

class _LeadDetailsScreenState extends State<LeadDetailsScreen> {
  final _noteController = TextEditingController();
  String? _noteError;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  LeadModel? _findLead(LeadProvider provider) {
    try {
      return provider.allLeads.firstWhere((l) => l.id == widget.leadId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _call(LeadModel lead) async {
    final ok = await LauncherHelper.call(lead.phone);
    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Could not open dialer')));
      // Still log the attempt note as per prompt? "After the call button is tapped..."
      // The prompt states to add note and change status after tap; if dialer fails
      // we show snackbar but can still record the attempt.
    }
    final now = DateTime.now();
    final noteText =
        'Called on ${DateFormat('dd MMM yyyy, h:mm a').format(now)}';
    final provider = context.read<LeadProvider>();
    await provider.addNote(lead.id, noteText);
    if (lead.status == 'New') {
      await provider.changeStatus(lead.id, 'Contacted');
    }
  }

  Future<void> _addNote() async {
    final err = noteValidator(_noteController.text);
    setState(() => _noteError = err);
    if (err != null) return;
    await context.read<LeadProvider>().addNote(
      widget.leadId,
      _noteController.text,
    );
    _noteController.clear();
    if (!mounted) return;
    setState(() => _noteError = null);
  }

  Future<void> _deleteLead(LeadModel lead) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete lead'),
        content: Text('Delete ${lead.name}? This cannot be undone here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    await context.read<LeadProvider>().deleteLead(lead.id);
    if (!mounted) return;
    context.pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('${lead.name} deleted')));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeadProvider>();
    final lead = _findLead(provider);
    if (lead == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lead details')),
        body: const Center(child: Text('Lead not found')),
      );
    }

    final df = DateFormat('dd MMM yyyy, h:mm a');
    final notes = provider.notesFor(lead.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lead details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit lead',
            onPressed: () => context.push(kRouteAddEditLead, extra: lead),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete lead',
            onPressed: () => _deleteLead(lead),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Hero(
                  tag: widget.heroTag ?? 'lead-${lead.id}',
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: statusColor(lead.status)
                        .withValues(alpha: 0.15),
                    backgroundImage:
                        lead.photoUrl != null && lead.photoUrl!.isNotEmpty
                        ? NetworkImage(lead.photoUrl!)
                        : null,
                    child: (lead.photoUrl == null || lead.photoUrl!.isEmpty)
                        ? Text(
                            lead.initials,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: statusColor(lead.status),
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lead.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (lead.company.isNotEmpty)
                        Text(
                          lead.company,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      const SizedBox(height: 6),
                      StatusChip(status: lead.status),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () => _call(lead),
                icon: const Icon(Icons.call),
                label: const Text('Call'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _InfoRow(
                      icon: Icons.phone,
                      label: 'Phone',
                      value: lead.phone,
                    ),
                    _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: lead.email.isEmpty ? '—' : lead.email,
                    ),
                    _InfoRow(
                      icon: Icons.source,
                      label: 'Source',
                      value: lead.source,
                    ),
                    _InfoRow(
                      icon: Icons.calendar_today,
                      label: 'Created',
                      value: df.format(lead.createdAt),
                    ),
                    _InfoRow(
                      icon: Icons.update,
                      label: 'Last updated',
                      value: df.format(lead.updatedAt),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      // ignore: deprecated_member_use
                      value: lead.status,
                      decoration: const InputDecoration(
                        labelText: 'Change status',
                      ),
                      items: kLeadStatuses
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          context.read<LeadProvider>().changeStatus(lead.id, v);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteController,
                      maxLength: kMaxNoteLength,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Add a note...',
                        errorText: _noteError,
                      ),
                      onChanged: (_) {
                        if (_noteError != null) {
                          setState(() => _noteError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: _addNote,
                        icon: const Icon(Icons.add),
                        label: const Text('Add note'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (notes.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No notes yet.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      )
                    else
                      ...notes.map(
                        (n) => NoteTile(
                          note: n,
                          onDelete: () =>
                              context.read<LeadProvider>().deleteNote(n.id),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
