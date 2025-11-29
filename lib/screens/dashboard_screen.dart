import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedMenu = 'Dashboard';
  bool _showProfileDropdown = false;
  bool _prescriptionExpanded = false;

  final List<Map<String, dynamic>> _menuItems = [
    {'icon': Icons.dashboard_outlined, 'title': 'Dashboard', 'hasSubmenu': false},
    {'icon': Icons.calendar_today_outlined, 'title': 'Appointment', 'hasSubmenu': false},
    {
      'icon': Icons.medication_outlined,
      'title': 'Prescription',
      'hasSubmenu': true,
      'submenu': [
        'All Prescription',
        'Create New RX',
        'Configuration',
      ]
    },
    {'icon': Icons.analytics_outlined, 'title': 'Analytics', 'hasSubmenu': false},
    {'icon': Icons.local_pharmacy_outlined, 'title': 'Drug Database', 'hasSubmenu': false},
    {'icon': Icons.settings_outlined, 'title': 'Settings', 'hasSubmenu': false},
  ];

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
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Stack(
        children: [
          Row(
        children: [
          // Sidebar
          Container(
            width: 260,
            decoration: const BoxDecoration(
              color: Color(0xFFFE3001),
            ),
            child: Column(
              children: [
                // Logo Section
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white24,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/horizental-logo-white.png',
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                
                // Menu Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                    children: _buildMenuItems(),
                  ),
                ),
                
                // Logout Button at Bottom
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.white24,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _handleLogout,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout,
                              size: 20,
                              color: Colors.white,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Logout',
                              style: TextStyle(
                                fontFamily: 'ProductSans',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Main Content Area
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        // Page Title
                        Text(
                          _selectedMenu,
                          style: const TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const Spacer(),
                        
                        // Search Icon
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.search,
                            color: Colors.grey.shade600,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        
                        // Notifications Icon
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.notifications_outlined,
                            color: Colors.grey.shade600,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Profile Avatar Button
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showProfileDropdown = !_showProfileDropdown;
                            });
                          },
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFFFE3001),
                            child: Text(
                              user?.name?.substring(0, 1).toUpperCase() ?? 'D',
                              style: const TextStyle(
                                fontFamily: 'ProductSans',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Content Area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.dashboard_outlined,
                              size: 80,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Content Area',
                              style: TextStyle(
                                fontFamily: 'ProductSans',
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Selected: $_selectedMenu',
                              style: TextStyle(
                                fontFamily: 'ProductSans',
                                fontSize: 16,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
          
          // Dropdown Overlay (on top of everything)
          if (_showProfileDropdown)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _showProfileDropdown = false;
                  });
                },
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
          
          // Dropdown Menu (positioned absolutely)
          if (_showProfileDropdown)
            Positioned(
              top: 70,
              right: 30,
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // User Info
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Doctor',
                              style: const TextStyle(
                                fontFamily: 'ProductSans',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A1A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                fontFamily: 'ProductSans',
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        height: 1,
                        color: Colors.grey.shade200,
                      ),
                      
                      // Menu Items
                      _buildDropdownItem(
                        icon: Icons.person_outline,
                        title: 'Profile',
                        onTap: () {
                          setState(() {
                            _showProfileDropdown = false;
                          });
                          // Navigate to profile
                        },
                      ),
                      _buildDropdownItem(
                        icon: Icons.settings_outlined,
                        title: 'Settings',
                        onTap: () {
                          setState(() {
                            _showProfileDropdown = false;
                          });
                          // Navigate to settings
                        },
                      ),
                      Divider(
                        height: 1,
                        color: Colors.grey.shade200,
                      ),
                      _buildDropdownItem(
                        icon: Icons.logout,
                        title: 'Logout',
                        isDestructive: true,
                        onTap: () {
                          setState(() {
                            _showProfileDropdown = false;
                          });
                          _handleLogout();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildMenuItems() {
    List<Widget> widgets = [];
    
    for (var item in _menuItems) {
      final isSelected = _selectedMenu == item['title'];
      final hasSubmenu = item['hasSubmenu'] == true;
      
      // Main menu item
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  if (hasSubmenu) {
                    _prescriptionExpanded = !_prescriptionExpanded;
                  } else {
                    _selectedMenu = item['title'];
                  }
                });
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      item['icon'],
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item['title'],
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    if (hasSubmenu)
                      Icon(
                        _prescriptionExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        size: 20,
                        color: Colors.white,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      
      // Submenu items
      if (hasSubmenu && _prescriptionExpanded) {
        final submenu = item['submenu'] as List<dynamic>;
        for (var subItem in submenu) {
          final isSubSelected = _selectedMenu == subItem;
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 4),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedMenu = subItem;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSubSelected
                          ? Colors.white.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      subItem,
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 14,
                        fontWeight: isSubSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      }
    }
    
    return widgets;
  }

  Widget _buildDropdownItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDestructive ? Colors.red : Colors.grey.shade700,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDestructive ? Colors.red : const Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
