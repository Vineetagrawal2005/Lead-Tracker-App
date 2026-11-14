import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/theme.dart';
import '../models/lead_model.dart';
import 'status_chip.dart';

class LeadCard extends StatelessWidget {
  const LeadCard({
    super.key,
    required this.lead,
    required this.onTap,
    this.heroTag,
  });

  final LeadModel lead;
  final VoidCallback onTap;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM, h:mm a');
    final avatar = CircleAvatar(
      radius: 24,
      backgroundColor: statusColor(lead.status).withValues(alpha: 0.15),
      backgroundImage: lead.photoUrl != null && lead.photoUrl!.isNotEmpty
          ? NetworkImage(lead.photoUrl!)
          : null,
      onBackgroundImageError: (exception, stackTrace) {},
      child: (lead.photoUrl == null || lead.photoUrl!.isEmpty)
          ? Text(
              lead.initials,
              style: TextStyle(
                color: statusColor(lead.status),
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Hero(tag: heroTag ?? 'lead-${lead.id}', child: avatar),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lead.name,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        StatusChip(status: lead.status, compact: true),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lead.phone,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    if (lead.company.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        lead.company,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      'Updated ${dateFormat.format(lead.updatedAt)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
