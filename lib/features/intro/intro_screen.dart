import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:go_router/go_router.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  List<PageViewModel> _buildPages(BuildContext context) {
    final theme = Theme.of(context);
    return [
      PageViewModel(title: 'Welcome to InfluInbox', body: 'Your smart inbox assistant built for creators and influencers.', image: _buildImage('logo.png'), decoration: _pageDecoration(theme)),
      PageViewModel(title: 'Organize Brand Deals', body: 'Automatically categorize sponsorship emails, proposals, and contracts.', image: _buildIcon(Icons.folder_special_outlined), decoration: _pageDecoration(theme)),
      PageViewModel(title: 'Smart Summaries', body: 'Get instant summaries of long email threads and contracts.', image: _buildIcon(Icons.summarize_outlined), decoration: _pageDecoration(theme)),
      PageViewModel(title: 'Automated Follow-ups', body: 'Never lose a deal. We remind you and draft polite follow-ups.', image: _buildIcon(Icons.schedule_send_outlined), decoration: _pageDecoration(theme)),
      PageViewModel(title: 'Deliverable Tracking', body: 'Track campaign assets, due dates, and submitted posts in one place.', image: _buildIcon(Icons.checklist_rtl), decoration: _pageDecoration(theme)),
    ];
  }

  static Widget _buildImage(String asset) => Center(child: Image.asset('assets/logo/$asset', height: 180));
  static Widget _buildIcon(IconData icon) => Center(child: Icon(icon, size: 140));

  PageDecoration _pageDecoration(ThemeData theme) {
    return PageDecoration(
      titleTextStyle: theme.textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.bold),
      bodyTextStyle: theme.textTheme.bodyLarge!,
      imagePadding: const EdgeInsets.only(top: 32),
      pageColor: theme.colorScheme.surface,
      bodyPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalBackgroundColor: Theme.of(context).colorScheme.surface,
      pages: _buildPages(context),
      showSkipButton: true,
      skip: const Text('Skip'),
      next: const Icon(Icons.arrow_forward),
      done: const Text('Get Started', style: TextStyle(fontWeight: FontWeight.w600)),
      dotsDecorator: const DotsDecorator(
        size: Size(10, 10),
        activeSize: Size(22, 10),
        activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25.0))),
      ),
      onDone: () => context.go('/login'),
      onSkip: () => context.go('/login'),
    );
  }
}
