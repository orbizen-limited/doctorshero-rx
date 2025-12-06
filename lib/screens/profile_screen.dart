import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load user data if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user == null) {
        authProvider.loadUser();
      }
    });
  }

  Future<void> _handleLogout() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.logout();
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFE3001),
              ),
            );
          }

          final user = authProvider.user;
          if (user == null) {
            return const Center(
              child: Text('No user data available'),
            );
          }

          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: const Color(0xFFFE3001),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'Profile',
                    style: const TextStyle(
                      fontFamily: 'ProductSans',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFFE3001),
                          const Color(0xFFFF5722),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: _handleLogout,
                    tooltip: 'Logout',
                  ),
                ],
              ),
              
              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Profile Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              // Avatar
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFFFE3001),
                                      const Color(0xFFFF5722),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    user.name.isNotEmpty 
                                        ? user.name[0].toUpperCase()
                                        : 'D',
                                    style: const TextStyle(
                                      fontFamily: 'ProductSans',
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              
                              // Name
                              Text(
                                user.name,
                                style: const TextStyle(
                                  fontFamily: 'ProductSans',
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              
                              // Role Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFE3001).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  user.role.toUpperCase(),
                                  style: const TextStyle(
                                    fontFamily: 'ProductSans',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFE3001),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              
                              // Divider
                              Divider(color: Colors.grey.shade300),
                              const SizedBox(height: 24),
                              
                              // Info Items
                              _buildInfoItem(
                                icon: Icons.email_outlined,
                                label: 'Email',
                                value: user.email,
                              ),
                              const SizedBox(height: 20),
                              
                              if (user.phone != null && user.phone!.isNotEmpty)
                                _buildInfoItem(
                                  icon: Icons.phone_outlined,
                                  label: 'Phone',
                                  value: user.phone!,
                                ),
                              
                              if (user.phone != null && user.phone!.isNotEmpty)
                                const SizedBox(height: 20),
                              
                              if (user.createdAt != null)
                                _buildInfoItem(
                                  icon: Icons.calendar_today_outlined,
                                  label: 'Member Since',
                                  value: _formatDate(user.createdAt!),
                                ),
                              
                              // Notification Preferences
                              if (user.notificationPreferences != null) ...[
                                const SizedBox(height: 32),
                                Divider(color: Colors.grey.shade300),
                                const SizedBox(height: 24),
                                
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Notification Preferences',
                                    style: TextStyle(
                                      fontFamily: 'ProductSans',
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                _buildNotificationItem(
                                  'SMS Notifications',
                                  user.notificationPreferences!['sms_notifications'] ?? false,
                                ),
                                const SizedBox(height: 12),
                                
                                _buildNotificationItem(
                                  'Email Notifications',
                                  user.notificationPreferences!['email_notifications'] ?? false,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Logout Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _handleLogout,
                          icon: const Icon(Icons.logout),
                          label: const Text(
                            'Logout',
                            style: TextStyle(
                              fontFamily: 'ProductSans',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFFE3001).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFFFE3001),
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'ProductSans',
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(String label, bool enabled) {
    return Row(
      children: [
        Icon(
          enabled ? Icons.check_circle : Icons.cancel,
          color: enabled ? Colors.green : Colors.grey,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Text(
          enabled ? 'Enabled' : 'Disabled',
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 14,
            color: enabled ? Colors.green : Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
