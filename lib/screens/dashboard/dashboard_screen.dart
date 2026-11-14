import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/lead_provider.dart';
import '../../widgets/lead_card.dart';
import '../../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, this.onViewAllLeads});

  final VoidCallback? onViewAllLeads;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final leadProvider = context.watch<LeadProvider>();
    final user = auth.currentUser;
    final firstName = (user?.name.split(' ').first) ?? 'there';
    final today = DateFormat('EEEE, d MMM yyyy').format(DateTime.now());

    final total = leadProvider.totalCount;
    final newCount = leadProvider.countByStatus('New');
    final contactedCount = leadProvider.countByStatus('Contacted');
    final convertedCount = leadProvider.countByStatus('Converted');
    final rate = leadProvider.conversionRate;
    final recent = leadProvider.recentLeads;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final ok = await context.read<LeadProvider>().refreshFromApi();
            if (!context.mounted) return;
            if (!ok && leadProvider.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(leadProvider.errorMessage!)),
              );
            }
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Hello, $firstName',
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                today,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.25,
                    children: [
                      StatCard(
                        title: 'Total Leads',
                        value: '$total',
                        icon: Icons.people,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      StatCard(
                        title: 'New',
                        value: '$newCount',
                        icon: Icons.fiber_new,
                        color: kStatusNewColor,
                      ),
                      StatCard(
                        title: 'Contacted',
                        value: '$contactedCount',
                        icon: Icons.phone_in_talk,
                        color: kStatusContactedColor,
                      ),
                      StatCard(
                        title: 'Converted',
                        value: '$convertedCount',
                        icon: Icons.check_circle,
                        color: kStatusConvertedColor,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conversion rate',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: rate,
                                minHeight: 10,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  kStatusConvertedColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${(rate * 100).toStringAsFixed(1)}%',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _StatusBar(
                        newCount: newCount,
                        contactedCount: contactedCount,
                        convertedCount: convertedCount,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent leads',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: onViewAllLeads,
                    child: const Text('View all'),
                  ),
                ],
              ),
              if (recent.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No leads yet. Add or load leads to get started.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ...recent.map(
                  (lead) => LeadCard(
                    lead: lead,
                    heroTag: 'dash-${lead.id}',
                    onTap: () => context.push(
                      '$kRouteLeadDetails/${lead.id}',
                      extra: 'dash-${lead.id}',
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.newCount,
    required this.contactedCount,
    required this.convertedCount,
  });

  final int newCount;
  final int contactedCount;
  final int convertedCount;

  @override
  Widget build(BuildContext context) {
    final total = newCount + contactedCount + convertedCount;
    if (total == 0) {
      return Container(
        height: 12,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                if (newCount > 0)
                  Expanded(
                    flex: newCount,
                    child: Container(color: kStatusNewColor),
                  ),
                if (contactedCount > 0)
                  Expanded(
                    flex: contactedCount,
                    child: Container(color: kStatusContactedColor),
                  ),
                if (convertedCount > 0)
                  Expanded(
                    flex: convertedCount,
                    child: Container(color: kStatusConvertedColor),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          children: const [
            _Legend(color: kStatusNewColor, label: 'New'),
            _Legend(color: kStatusContactedColor, label: 'Contacted'),
            _Legend(color: kStatusConvertedColor, label: 'Converted'),
          ],
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
