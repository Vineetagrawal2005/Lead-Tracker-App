import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants.dart';
import '../../providers/lead_provider.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/filter_chips_bar.dart';
import '../../widgets/lead_card.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/search_bar_field.dart';

class LeadsListScreen extends StatelessWidget {
  const LeadsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeadProvider>();
    final leads = provider.filteredLeads;

    // Counts for chips respect search but not status filter.
    final q = provider.searchQuery.toLowerCase();
    final searched = provider.allLeads.where((l) {
      if (q.isEmpty) return true;
      return l.name.toLowerCase().contains(q) ||
          l.phone.contains(q) ||
          l.email.toLowerCase().contains(q) ||
          l.company.toLowerCase().contains(q);
    }).toList();
    final counts = <String, int>{
      'All': searched.length,
      'New': searched.where((l) => l.status == 'New').length,
      'Contacted': searched.where((l) => l.status == 'Contacted').length,
      'Converted': searched.where((l) => l.status == 'Converted').length,
    };

    Widget body;
    if (provider.status == LeadListStatus.loading) {
      body = const LoadingView(message: 'Loading leads...');
    } else if (provider.status == LeadListStatus.error &&
        provider.allLeads.isEmpty) {
      body = ErrorView(
        message: provider.errorMessage ?? 'Could not load leads.',
        onRetry: () => context.read<LeadProvider>().loadLeads(),
      );
    } else if (provider.allLeads.isEmpty) {
      body = const EmptyView(
        icon: Icons.people_outline,
        message: 'No leads yet. Tap + to add your first lead.',
      );
    } else if (leads.isEmpty) {
      body = const EmptyView(
        icon: Icons.search_off,
        message: 'No results match your search or filter.',
      );
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.only(bottom: 88),
        itemCount: leads.length,
        itemBuilder: (context, index) {
          final lead = leads[index];
          return Dismissible(
            key: ValueKey(lead.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: Theme.of(context).colorScheme.error,
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (_) async {
              // Use undo snackbar instead of confirm dialog for quick flow.
              return true;
            },
            onDismissed: (_) async {
              final p = context.read<LeadProvider>();
              await p.deleteLead(lead.id);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${lead.name} deleted'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () {
                      p.undoDeleteLead();
                    },
                  ),
                ),
              );
            },
            child: LeadCard(
              lead: lead,
              heroTag: 'list-${lead.id}',
              onTap: () => context.push(
                '$kRouteLeadDetails/${lead.id}',
                extra: 'list-${lead.id}',
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Leads (${provider.totalCount})'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Sort',
            icon: const Icon(Icons.sort),
            initialValue: provider.sortOption,
            onSelected: (v) => context.read<LeadProvider>().setSort(v),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'Newest first', child: Text('Newest first')),
              PopupMenuItem(value: 'Oldest first', child: Text('Oldest first')),
              PopupMenuItem(value: 'Name A-Z', child: Text('Name A-Z')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(kRouteAddEditLead),
        tooltip: 'Add lead',
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          SearchBarField(
            onChanged: (v) => context.read<LeadProvider>().setSearch(v),
          ),
          FilterChipsBar(
            selected: provider.selectedFilter,
            counts: counts,
            onSelected: (v) => context.read<LeadProvider>().setFilter(v),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final p = context.read<LeadProvider>();
                final ok = await p.refreshFromApi();
                if (!context.mounted) return;
                if (!ok && p.allLeads.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(p.errorMessage ?? 'Could not refresh'),
                    ),
                  );
                }
              },
              child: body is ListView
                  ? body
                  : ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [SizedBox(height: 400, child: body)],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
