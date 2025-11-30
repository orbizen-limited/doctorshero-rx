import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardContent extends StatelessWidget {
  const DashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Search Bar
              Container(
                width: 300,
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search By Name Or Category',
                    hintStyle: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 14,
                      fontFamily: 'ProductSans',
                    ),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF64748B)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              
              // Action Buttons
              Row(
                children: [
                  _buildActionButton(
                    label: 'Add RX',
                    icon: Icons.add,
                    color: const Color(0xFFFE3001),
                    onTap: () {},
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    label: 'Get Appointment',
                    icon: Icons.calendar_today,
                    color: const Color(0xFFFE3001),
                    onTap: () {},
                  ),
                  const SizedBox(width: 12),
                  _buildActionButton(
                    label: 'Add Patient',
                    icon: Icons.person_add,
                    color: const Color(0xFFFE3001),
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Dashboard Title
          const Text(
            'Dashboard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              fontFamily: 'ProductSans',
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Stats Cards
          Row(
            children: [
              Expanded(child: _buildStatCard('TotalPatent', '20', const Color(0xFF3B82F6), Icons.people)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Old Patent', '20', const Color(0xFFF59E0B), Icons.person)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('New Patent', '20', const Color(0xFF10B981), Icons.person_add)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Follow Up', '20', const Color(0xFF8B5CF6), Icons.refresh)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Reports', '20', const Color(0xFFEF4444), Icons.description)),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard('Pending', '20', const Color(0xFF6366F1), Icons.pending)),
            ],
          ),
          
          const SizedBox(height: 30),
          
          // Today's Task Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TodaysTask',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  fontFamily: 'ProductSans',
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFFFE3001),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'View More',
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Content Row: Task Table + Charts
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Table
              Expanded(
                flex: 2,
                child: _buildTaskTable(),
              ),
              
              const SizedBox(width: 24),
              
              // Charts Column
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildWeeklyChart(),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(child: _buildPieChart('Patient Gender', _getGenderData())),
                        const SizedBox(width: 16),
                        Expanded(child: _buildPieChart('Patient Type', _getPatientTypeData())),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(
          fontFamily: 'ProductSans',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontFamily: 'ProductSans',
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              fontFamily: 'ProductSans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                  flex: 3,
                  child: Text(
                    'NAME',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      fontFamily: 'ProductSans',
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'PATIENT TYPE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      fontFamily: 'ProductSans',
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'STATUS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      fontFamily: 'ProductSans',
                    ),
                  ),
                ),
                const Expanded(
                  flex: 2,
                  child: Text(
                    'ACTIONS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      fontFamily: 'ProductSans',
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Table Rows
          ...List.generate(5, (index) => _buildTableRow()),
          
          // Pagination
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '1 in 100 entries',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    fontFamily: 'ProductSans',
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chevron_left, size: 20),
                      color: const Color(0xFF64748B),
                    ),
                    ...List.generate(5, (index) => _buildPageButton(index + 1, index == 0)),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chevron_right, size: 20),
                      color: const Color(0xFF64748B),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF1F5F9)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFE2E8F0),
                  child: const Text(
                    'MM',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mir Monir',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                        fontFamily: 'ProductSans',
                      ),
                    ),
                    Text(
                      'Visited At: 16-Jan-2025 05:25',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                        fontFamily: 'ProductSans',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Expanded(
            flex: 2,
            child: Text(
              'NEW',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
                fontFamily: 'ProductSans',
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Completed',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF10B981),
                  fontFamily: 'ProductSans',
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  color: const Color(0xFFFE3001),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  color: const Color(0xFF3B82F6),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  color: const Color(0xFF10B981),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton(int page, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF10B981) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isActive ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Center(
        child: Text(
          '$page',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF64748B),
            fontFamily: 'ProductSans',
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Patent Of This Week',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  fontFamily: 'ProductSans',
                ),
              ),
              const Text(
                'Overview Of Patient',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  fontFamily: 'ProductSans',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 500,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['1', '2', '3', '4', '5', '6', '7'];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            days[value.toInt() % 7],
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                              fontFamily: 'ProductSans',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                            fontFamily: 'ProductSans',
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 100,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFF1F5F9),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _buildBarGroup(0, 300),
                  _buildBarGroup(1, 200),
                  _buildBarGroup(2, 400),
                  _buildBarGroup(3, 450),
                  _buildBarGroup(4, 350),
                  _buildBarGroup(5, 380),
                  _buildBarGroup(6, 420),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFF6366F1),
          width: 24,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildPieChart(String title, List<PieChartData> data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 35,
                    sections: data.map((item) {
                      return PieChartSectionData(
                        color: item.color,
                        value: item.value,
                        title: '${item.percentage}%',
                        radius: 35,
                        titleStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'ProductSans',
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...data.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${item.label} ●',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontFamily: 'ProductSans',
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  List<PieChartData> _getGenderData() {
    return [
      PieChartData(label: 'Male', value: 54, percentage: 54, color: const Color(0xFF10B981)),
      PieChartData(label: 'Female', value: 30, percentage: 30, color: const Color(0xFFEC4899)),
      PieChartData(label: 'Baby', value: 16, percentage: 16, color: const Color(0xFF3B82F6)),
    ];
  }

  List<PieChartData> _getPatientTypeData() {
    return [
      PieChartData(label: 'New', value: 60, percentage: 60, color: const Color(0xFF10B981)),
      PieChartData(label: 'Old', value: 28, percentage: 28, color: const Color(0xFF6366F1)),
      PieChartData(label: 'Baby', value: 12, percentage: 12, color: const Color(0xFF3B82F6)),
    ];
  }
}

class PieChartData {
  final String label;
  final double value;
  final int percentage;
  final Color color;

  PieChartData({
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
  });
}
