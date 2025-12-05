import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../services/auth_v2_service.dart';

class SessionManagementScreen extends StatefulWidget {
  const SessionManagementScreen({super.key});

  @override
  State<SessionManagementScreen> createState() => _SessionManagementScreenState();
}

class _SessionManagementScreenState extends State<SessionManagementScreen> {
  final AuthV2Service _authService = AuthV2Service();
  List<SessionModel> _sessions = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _totalSessions = 0;
  int _maxAllowed = 4;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  Future<void> _loadSessions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authService.getActiveSessions();

    if (result['success'] == true) {
      setState(() {
        _sessions = (result['sessions'] as List)
            .map((json) => SessionModel.fromJson(json))
            .toList();
        _totalSessions = result['total'] ?? _sessions.length;
        _maxAllowed = result['max_allowed'] ?? 4;
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'] ?? 'Failed to load sessions';
        _isLoading = false;
      });
    }
  }

  Future<void> _revokeSession(SessionModel session) async {
    // Confirm before revoking
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Revoke Session'),
        content: Text(
          'Are you sure you want to logout from:\n\n${session.device}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Revoke'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final result = await _authService.revokeSession(session.id);

    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Session revoked successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _loadSessions(); // Reload sessions
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to revoke session'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _logoutAllDevices() async {
    // Confirm before logging out all
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout All Devices'),
        content: const Text(
          'This will logout from all devices including this one. You will need to login again.\n\nAre you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout All'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await _authService.logoutAll();

    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out from all devices'),
          backgroundColor: Colors.green,
        ),
      );
      // Navigate to login screen
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to logout from all devices'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Sessions'),
        actions: [
          if (_sessions.length > 1)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout All Devices',
              onPressed: _logoutAllDevices,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadSessions,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Session count header
                    Container(
                      padding: const EdgeInsets.all(16),
                      color: Colors.blue.shade50,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Active Sessions: $_totalSessions / $_maxAllowed',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _loadSessions,
                          ),
                        ],
                      ),
                    ),
                    
                    // Sessions list
                    Expanded(
                      child: _sessions.isEmpty
                          ? const Center(
                              child: Text('No active sessions'),
                            )
                          : ListView.builder(
                              itemCount: _sessions.length,
                              itemBuilder: (context, index) {
                                final session = _sessions[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: ListTile(
                                    leading: Text(
                                      session.deviceIcon,
                                      style: const TextStyle(fontSize: 32),
                                    ),
                                    title: Text(
                                      session.device,
                                      style: TextStyle(
                                        fontWeight: session.isCurrent
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Last used: ${session.formattedLastUsed}'),
                                        if (session.isCurrent)
                                          const Text(
                                            'Current device',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: session.isCurrent
                                        ? const Chip(
                                            label: Text('Active'),
                                            backgroundColor: Colors.green,
                                            labelStyle: TextStyle(color: Colors.white),
                                          )
                                        : IconButton(
                                            icon: const Icon(Icons.logout, color: Colors.red),
                                            tooltip: 'Revoke',
                                            onPressed: () => _revokeSession(session),
                                          ),
                                  ),
                                );
                              },
                            ),
                    ),
                    
                    // Warning if close to max
                    if (_totalSessions >= _maxAllowed - 1)
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.orange.shade100,
                        child: Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.orange),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _totalSessions >= _maxAllowed
                                    ? 'Maximum sessions reached. Revoke a session to login from another device.'
                                    : 'You have 1 session slot remaining.',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
    );
  }
}
