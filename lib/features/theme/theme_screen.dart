import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    final appTypography = theme.extension<AppTypography>()!;
    return Scaffold(
      appBar: AppBar(title: Text('Theme Showcase', style: appTypography.logo)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Text Styles', style: appTypography.sectionTitle),
            const SizedBox(height: 8),
            Text('Logo Style', style: appTypography.logo),
            Text('Section Title', style: appTypography.sectionTitle),
            Text('Display Large', style: theme.textTheme.displayLarge),
            Text('Headline Medium', style: theme.textTheme.headlineMedium),
            Text('Title Large', style: theme.textTheme.titleLarge),
            Text('Body Medium', style: theme.textTheme.bodyMedium),
            Text('Label Small', style: theme.textTheme.labelSmall),
            const Divider(height: 32),
            Text('Buttons', style: appTypography.sectionTitle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(onPressed: () {}, child: const Text('Elevated')),
                OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
                TextButton(onPressed: () {}, child: const Text('Text')),
                IconButton(onPressed: () {}, icon: const Icon(Icons.star)),
                FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
              ],
            ),
            const Divider(height: 32),
            Text('Inputs', style: appTypography.sectionTitle),
            const SizedBox(height: 8),
            TextField(decoration: const InputDecoration(labelText: 'Text Field')),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: 'One',
              items: const [
                DropdownMenuItem(value: 'One', child: Text('One')),
                DropdownMenuItem(value: 'Two', child: Text('Two')),
              ],
              onChanged: (_) {},
            ),
            const Divider(height: 32),
            Text('Cards', style: appTypography.sectionTitle),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Card Title', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('This is a card with some content.', style: theme.textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
            const Divider(height: 32),
            Text('Color Swatches', style: appTypography.sectionTitle),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ColorBox(label: 'Brand', color: appColors.brand),
                _ColorBox(label: 'Accent', color: appColors.accent),
                _ColorBox(label: 'Primary', color: theme.colorScheme.primary),
                _ColorBox(label: 'Secondary', color: theme.colorScheme.secondary),
                _ColorBox(label: 'Background', color: theme.colorScheme.surface),
                _ColorBox(label: 'Surface', color: theme.colorScheme.surface),
                _ColorBox(label: 'Error', color: theme.colorScheme.error),
                _ColorBox(label: 'On Primary', color: theme.colorScheme.onPrimary),
                _ColorBox(label: 'On Background', color: theme.colorScheme.onSurface),
              ],
            ),
            const Divider(height: 32),
            Text('Email List Tile', style: appTypography.sectionTitle),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: appColors.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.person, color: Colors.white, size: 28),
                ),
                title: Text('Brand Name', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text('Subject: Sponsored Post Opportunity', style: theme.textTheme.bodyMedium),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('2:45 PM', style: theme.textTheme.labelSmall),
                    const SizedBox(height: 4),
                    Icon(Icons.mark_email_unread, color: appColors.brand, size: 18),
                  ],
                ),
              ),
            ),
            const Divider(height: 32),
            Text('Email Detail Card', style: appTypography.sectionTitle),
            const SizedBox(height: 8),
            Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(color: appColors.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.person, color: Colors.white, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Brand Name', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            Text('brand@email.com', style: theme.textTheme.bodySmall),
                          ],
                        ),
                        const Spacer(),
                        Text('Apr 4, 2025', style: theme.textTheme.labelSmall),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text('Subject: Sponsored Post Opportunity', style: appTypography.sectionTitle),
                    const SizedBox(height: 10),
                    Text('Hi! We loved your recent content and would like to offer a paid collaboration for our new product launch. Let us know if you’re interested!', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(label: const Text('Deal'), backgroundColor: appColors.brand.withValues(alpha: 0.15)),
                        Chip(label: const Text('Unread'), backgroundColor: appColors.accent.withValues(alpha: 0.15)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.reply), label: const Text('Reply')),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.archive), label: const Text('Archive')),
                        const SizedBox(width: 8),
                        IconButton(onPressed: () {}, icon: const Icon(Icons.report_gmailerrorred)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 32),
            Text('AI Reply Suggestion', style: appTypography.sectionTitle),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: appColors.brand.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                child: Text('"Thanks for reaching out! I’d love to learn more about your campaign and discuss next steps."', style: theme.textTheme.bodyMedium),
              ),
            ),
            const Divider(height: 32),
            Text('Campaign/Contract Summary', style: appTypography.sectionTitle),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Brand: Acme Co.', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('Deliverables: 1 IG Post, 2 Stories', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text('Due: Apr 20, 2025', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: 0.5, minHeight: 8, backgroundColor: appColors.brand.withValues(alpha: 0.15), color: appColors.accent),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Chip(label: const Text('Negotiation'), backgroundColor: appColors.accent.withValues(alpha: 0.15)),
                        const SizedBox(width: 8),
                        Chip(label: const Text('Contract'), backgroundColor: appColors.brand.withValues(alpha: 0.15)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 32),
            Text('Analytics / Metrics', style: appTypography.sectionTitle),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _MetricBox(label: 'Open Rate', value: '82%'),
                    _MetricBox(label: 'Reply Rate', value: '67%'),
                    _MetricBox(label: 'ROI', value: '4.2x'),
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

class _ColorBox extends StatelessWidget {
  final String label;
  final Color color;
  const _ColorBox({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _MetricBox extends StatelessWidget {
  final String label;
  final String value;
  const _MetricBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
