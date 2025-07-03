import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_services.dart';

/// Main dashboard page after authentication
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _selectedIndex = 0;
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuthService.currentUser;

    // Listen to auth state changes
    FirebaseAuthService.authStateChanges.listen((User? user) {
      if (mounted) {
        setState(() {
          this.user = user;
        });

        // Redirect to auth if user signs out
        if (user == null) {
          Navigator.of(context).pushReplacementNamed('/auth');
        }
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuthService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/auth');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('InfluInbox'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (user?.photoURL != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(backgroundImage: NetworkImage(user!.photoURL!), radius: 16),
            ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _signOut();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'profile',
                child: ListTile(leading: const Icon(Icons.person), title: Text(user?.displayName ?? 'Profile'), subtitle: Text(user?.email ?? '')),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: ListTile(leading: Icon(Icons.logout), title: Text('Sign Out')),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Inbox'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildInboxView();
      case 1:
        return _buildAnalyticsView();
      case 2:
        return _buildSettingsView();
      default:
        return _buildInboxView();
    }
  }

  Widget _buildInboxView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Inbox View', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Email management features will be implemented here', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildAnalyticsView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Analytics View', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Email analytics and insights will be shown here', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildSettingsView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.settings, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Settings View', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('App settings and preferences will be configured here', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
