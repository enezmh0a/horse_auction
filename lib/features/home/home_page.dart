import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Very small dashboard summarizing Firestore `lots`.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('lots')
              .orderBy('updatedAt', descending: true)
              .snapshots(),
          builder: (context, snap) {
            if (snap.hasError) {
              return _ErrorBox(message: snap.error.toString());
            }
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final docs = snap.data!.docs;
            final total = docs.length;
            final live = docs.where((d) => d.data()['state'] == 'live').length;
            final closed =
                docs.where((d) => d.data()['state'] == 'closed').length;

            num? top;
            String? topTitle;
            String? topCity;
            for (final d in docs) {
              final data = d.data();
              final cur = (data['current'] ?? data['start']) as num?;
              if (cur != null && (top == null || cur > top!)) {
                top = cur;
                topTitle = (data['title'] as String?) ?? d.id;
                topCity = (data['city'] as String?) ?? '';
              }
            }

            final recent = docs.take(5).toList();

            return CustomScrollView(
              slivers: [
                const SliverAppBar(
                  pinned: true,
                  toolbarHeight: 64,
                  title: Text('Horse Auctions'),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverToBoxAdapter(
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final isWide = c.maxWidth >= 900;
                        final cols = isWide ? 4 : 2;
                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: cols,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: isWide ? 2.6 : 1.9,
                          children: [
                            _StatCard(
                              icon: Icons.list_alt,
                              label: 'Total lots',
                              value: '$total',
                            ),
                            _StatCard(
                              icon: Icons.play_circle_filled,
                              label: 'Live',
                              value: '$live',
                            ),
                            _StatCard(
                              icon: Icons.lock,
                              label: 'Closed',
                              value: '$closed',
                            ),
                            _StatCard(
                              icon: Icons.trending_up,
                              label: 'Top current',
                              value: top != null
                                  ? 'SAR ${top!.toStringAsFixed(0)}'
                                  : '--',
                              caption: topTitle ?? '',
                              trailing: (topCity?.isNotEmpty ?? false)
                                  ? Text(topCity!,
                                      style: theme.textTheme.labelMedium)
                                  : null,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverToBoxAdapter(
                    child:
                        Text('Recent lots', style: theme.textTheme.titleMedium),
                  ),
                ),
                SliverList.separated(
                  itemCount: recent.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final d = recent[i];
                    final data = d.data();
                    final title = (data['title'] as String?) ?? d.id;
                    final city = (data['city'] as String?) ?? '--';
                    final state = (data['state'] as String?) ?? '--';
                    final step = (data['step'] as num?) ?? 0;
                    final current = (data['current'] as num?) ?? 0;

                    return ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      title:
                          Text(title, maxLines: 1, overflow: TextOverflow.fade),
                      subtitle: Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _Chip(text: state == 'live' ? 'Live' : 'Closed'),
                          _Chip(text: 'City: $city'),
                          _Chip(text: 'Step: SAR ${step.toStringAsFixed(0)}'),
                          _Chip(
                              text:
                                  'Current: SAR ${current.toStringAsFixed(0)}'),
                        ],
                      ),
                      trailing: Icon(Icons.chevron_right,
                          color: Theme.of(context).colorScheme.outline),
                      onTap: () {},
                    );
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? caption;
  final Widget? trailing;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.caption,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (caption != null && caption!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(caption!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  const _ErrorBox({required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          Text('Error: $message', style: Theme.of(context).textTheme.bodyLarge),
    );
  }
}
