import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../services/auth_v2_service.dart';

/// Dialog shown when max sessions limit is reached
/// Allows user to select which session to revoke
class MaxSessionsDialog extends StatefulWidget {
  const MaxSessionsDialog({super.key});

  @override
  State<MaxSessionsDialog> createState() => _MaxSessionsDialogState();
}

class _MaxSessionsDialogState extends State<MaxSessionsDialog> {
  final AuthV2Service _authService = AuthV2Service();
  List<SessionModel> _sessions = [];
  bool _isLoading = true;
  String? _errorMessage;
  SessionModel? _selectedSession;

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
        _isLoading = false;
      });
    } else {
      setState(() {
        _errorMessage = result['message'] ?? 'Failed to load sessions';
        _isLoading = false;
      });
    }
  }

  Future<void> _revokeAndLogin() async {
    if (_selectedSession == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a session to revoke'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final result = await _authService.revokeSession(_selectedSession!.id);

    if (!mounted) return;
    Navigator.pop(context); // Close loading dialog

    if (result['success'] == true) {
      // Return true to indicate session was revoked successfully
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Failed to revoke session'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange),
          const SizedBox(width: 8),
          const Expanded(
            child: Text('Maximum Sessions Reached'),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: _isLoading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                ),
              )
            : _errorMessage != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadSessions,
                        child: const Text('Retry'),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'You have reached the maximum number of active sessions (4).',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please select a device to logout from:',
                      ),
                      const SizedBox(height: 16),
                      
                      // Sessions list
                      Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _sessions.length,
                          itemBuilder: (context, index) {
                            final session = _sessions[index];
                            final isSelected = _selectedSession?.id == session.id;
                            
                            return Card(
                              color: isSelected
                                  ? Colors.blue.shade50
                                  : null,
                              child: ListTile(
                                leading: Text(
                                  session.deviceIcon,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                title: Text(session.device),
                                subtitle: Text('Last used: ${session.formattedLastUsed}'),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle, color: Colors.blue)
                                    : null,
                                selected: isSelected,
                                onTap: () {
                                  setState(() {
                                    _selectedSession = session;
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading || _selectedSession == null
              ? null
              : _revokeAndLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Revoke & Login'),
        ),
      ],
    );
  }
}

/// Show max sessions dialog and return true if session was revoked
Future<bool> showMaxSessionsDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const MaxSessionsDialog(),
  );
  return result ?? false;
}
