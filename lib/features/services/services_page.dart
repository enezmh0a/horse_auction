import 'package:flutter/material.dart';

class ServicesPage extends StatelessWidget {
  const ServicesPage({super.key});

  bool _isArabic(BuildContext context) {
    final lc = Localizations.localeOf(context).languageCode;
    final dir = Directionality.of(context);
    return lc == 'ar' || dir == TextDirection.rtl;
  }

  @override
  Widget build(BuildContext context) {
    final ar = _isArabic(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(ar ? 'الخدمات' : 'Services'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _TierCard(
            title: ar ? 'بلاتينيوم' : 'Platinum',
            subtitle:
                ar ? 'أقصى ظهور + خدمة مخصصة' : 'Top exposure + concierge',
            bullets: ar
                ? const [
                    'أولوية في الصفحة الرئيسية',
                    'تصوير احترافي وفيديو',
                    'إدارة عروض ومزايدات مدارة',
                  ]
                : const [
                    'Homepage priority placement',
                    'Pro photography & video',
                    'Managed offers & bidding',
                  ],
            icon: Icons.workspace_premium,
          ),
          _TierCard(
            title: ar ? 'ذهبي' : 'Gold',
            subtitle:
                ar ? 'رؤية عالية وإعلان مميز' : 'High visibility & featured',
            bullets: ar
                ? const [
                    'مربع مميز في القوائم',
                    'تحليلات أساسية',
                    'دعم خلال أوقات العمل',
                  ]
                : const [
                    'Featured card in lists',
                    'Basic analytics',
                    'Business-hours support',
                  ],
            icon: Icons.star_rate,
          ),
          _TierCard(
            title: ar ? 'فضي' : 'Silver',
            subtitle: ar ? 'بداية قوية بتكلفة مناسبة' : 'Solid starter package',
            bullets: ar
                ? const [
                    'إدراج قياسي',
                    'صور أساسية',
                    'أسئلة وأجوبة عبر البريد',
                  ]
                : const [
                    'Standard listing',
                    'Basic photos',
                    'Email Q&A',
                  ],
            icon: Icons.star_border,
          ),
        ],
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.title,
    required this.subtitle,
    required this.bullets,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final List<String> bullets;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(subtitle, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  ...bullets.map(
                    (b) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check, size: 18),
                          const SizedBox(width: 6),
                          Expanded(child: Text(b)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
