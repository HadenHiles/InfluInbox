import 'package:flutter/material.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Theme Showcase')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Text Styles', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Display Large', style: theme.textTheme.displayLarge),
            Text('Headline Medium', style: theme.textTheme.headlineMedium),
            Text('Title Large', style: theme.textTheme.titleLarge),
            Text('Body Medium', style: theme.textTheme.bodyMedium),
            Text('Label Small', style: theme.textTheme.labelSmall),
            const Divider(height: 32),
            Text('Buttons', style: theme.textTheme.headlineSmall),
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
            Text('Inputs', style: theme.textTheme.headlineSmall),
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
            Text('Cards', style: theme.textTheme.headlineSmall),
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
            Text('Color Swatches', style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ColorBox(label: 'Primary', color: theme.colorScheme.primary),
                _ColorBox(label: 'Secondary', color: theme.colorScheme.secondary),
                _ColorBox(label: 'Background', color: theme.colorScheme.surface),
                _ColorBox(label: 'Surface', color: theme.colorScheme.surface),
                _ColorBox(label: 'Error', color: theme.colorScheme.error),
                _ColorBox(label: 'On Primary', color: theme.colorScheme.onPrimary),
                _ColorBox(label: 'On Background', color: theme.colorScheme.onSurface),
              ],
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
