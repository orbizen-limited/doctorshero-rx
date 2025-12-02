import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';
import '../services/patient_service.dart';

class AppointmentScreen extends StatefulWidget {
  final void Function({
    required String patientId,
    required String patientName,
    required String patientAge,
    required String patientGender,
    String? patientPhone,
  })? onCreateRx;

  const AppointmentScreen({
    super.key,
    this.onCreateRx,
  });

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  final AppointmentService _appointmentService = AppointmentService();
  final PatientService _patientService = PatientService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Appointment> _appointments = [];
  Map<int, String> _enrichedPids = {}; // appointmentId -> patientPid
  AppointmentStats? _stats;
  bool _isLoading = false;
  String _selectedView = 'Patient'; // Patient or Report
  String? _selectedStatus;
  String? _selectedDepartment;
  String? _selectedProvider;
  DateTime _selectedDate = DateTime.now();
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalEntries = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load stats
      final stats = await _appointmentService.getAppointmentStats(
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      );
      
      // Load appointments
      final result = await _appointmentService.getAppointments(
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        status: _selectedStatus,
        search: _searchController.text,
        page: _currentPage,
      );

      setState(() {
        _stats = stats;
        _appointments = result['appointments'];
        _totalPages = result['last_page'];
        _totalEntries = result['total'];
        _isLoading = false;
      });
      
      // Enrich appointments without PIDs
      _enrichAppointmentsWithPids();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }
  
  /// Enrich appointments without PIDs by searching patients by phone
  Future<void> _enrichAppointmentsWithPids() async {
    for (final appointment in _appointments) {
      // Skip if already has PID
      if (appointment.patientPid != null && appointment.patientPid!.isNotEmpty) {
        continue;
      }
      
      // Search patient by phone
      try {
        final patients = await _patientService.searchByPhone(appointment.phone);
        if (patients.isNotEmpty) {
          final patient = patients.first;
          if (patient['patient_id'] != null) {
            setState(() {
              _enrichedPids[appointment.id] = patient['patient_id'];
            });
          }
        }
      } catch (e) {
        // Silently fail for individual enrichments
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _currentPage = 1;
      });
      _loadData();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'cancelled':
        return const Color(0xFFE53935);
      case 'pending':
      case 'scheduled':
        return const Color(0xFF2196F3);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Stats Cards
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                _buildStatCard(
                  'TotalAppointment',
                  _stats?.totalAppointments.toString() ?? '0',
                  const Color(0xFF2196F3),
                  Icons.calendar_today,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Pending Tasks',
                  _stats?.pendingTasks.toString() ?? '0',
                  const Color(0xFFFFA726),
                  Icons.pending_actions,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'completed Task',
                  _stats?.completedTask.toString() ?? '0',
                  const Color(0xFF66BB6A),
                  Icons.check_circle,
                ),
                const SizedBox(width: 16),
                _buildStatCard(
                  'Cancelled Task',
                  _stats?.cancelledTask.toString() ?? '0',
                  const Color(0xFFEF5350),
                  Icons.cancel,
                ),
              ],
            ),
          ),

          // Filters and Search
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Search
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search By Name Or Category',
                        hintStyle: TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 14,
                          color: Colors.grey.shade400,
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _loadData(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Date Picker
                InkWell(
                  onTap: _selectDate,
                  child: Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        Text(
                          DateFormat('MM/dd/yy').format(_selectedDate),
                          style: const TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 14,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Department Filter
                _buildDropdownFilter('Department', _selectedDepartment, (value) {
                  setState(() {
                    _selectedDepartment = value;
                  });
                }),
                const SizedBox(width: 16),

                // Provider Filter
                _buildDropdownFilter('Provider', _selectedProvider, (value) {
                  setState(() {
                    _selectedProvider = value;
                  });
                }),
                const SizedBox(width: 16),

                // Status Filter
                _buildDropdownFilter('Status', _selectedStatus, (value) {
                  setState(() {
                    _selectedStatus = value;
                    _currentPage = 1;
                  });
                  _loadData();
                }),
                const SizedBox(width: 16),

                // View Toggle
                Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      _buildViewButton('Patient', _selectedView == 'Patient'),
                      _buildViewButton('Report', _selectedView == 'Report'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Table
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        _buildTableHeader('PATIENT NAME', flex: 3),
                        _buildTableHeader('PID', flex: 2),
                        _buildTableHeader('GENDER', flex: 1),
                        _buildTableHeader('AGE', flex: 1),
                        _buildTableHeader('DATE', flex: 2),
                        _buildTableHeader('TIME', flex: 1),
                        _buildTableHeader('PAYMENT STATUS', flex: 2),
                        _buildTableHeader('PRICE', flex: 1),
                        _buildTableHeader('STATUS', flex: 2),
                        _buildTableHeader('ACTIONS', flex: 2),
                      ],
                    ),
                  ),

                  // Table Body
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _appointments.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.event_busy, size: 64, color: Colors.grey.shade300),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No appointments found',
                                      style: TextStyle(
                                        fontFamily: 'ProductSans',
                                        fontSize: 16,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: _appointments.length,
                                itemBuilder: (context, index) {
                                  final appointment = _appointments[index];
                                  return _buildTableRow(appointment, index);
                                },
                              ),
                  ),

                  // Pagination
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '1 in $_totalEntries entries',
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _currentPage > 1
                                  ? () {
                                      setState(() {
                                        _currentPage--;
                                      });
                                      _loadData();
                                    }
                                  : null,
                              icon: const Icon(Icons.chevron_left),
                              iconSize: 20,
                            ),
                            ...List.generate(
                              _totalPages > 5 ? 5 : _totalPages,
                              (index) {
                                final pageNum = index + 1;
                                return _buildPageButton(pageNum);
                              },
                            ),
                            IconButton(
                              onPressed: _currentPage < _totalPages
                                  ? () {
                                      setState(() {
                                        _currentPage++;
                                      });
                                      _loadData();
                                    }
                                  : null,
                              icon: const Icon(Icons.chevron_right),
                              iconSize: 20,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 13,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownFilter(String hint, String? value, Function(String?) onChanged) {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              fontFamily: 'ProductSans',
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          icon: Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey.shade600),
          items: _getDropdownItems(hint),
          onChanged: onChanged,
          style: const TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 14,
            color: Color(0xFF1A1A1A),
          ),
        ),
      ),
    );
  }

  List<DropdownMenuItem<String>> _getDropdownItems(String type) {
    List<String> items = [];
    switch (type) {
      case 'Status':
        items = ['All', 'Scheduled', 'Completed', 'Cancelled'];
        break;
      case 'Department':
        items = ['All', 'Cardiology', 'Neurology', 'Pediatrics'];
        break;
      case 'Provider':
        items = ['All', 'Dr. Smith', 'Dr. Johnson'];
        break;
    }
    return items.map((item) {
      return DropdownMenuItem<String>(
        value: item == 'All' ? null : item,
        child: Text(item),
      );
    }).toList();
  }

  Widget _buildViewButton(String label, bool isSelected) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedView = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2196F3) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(String title, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'ProductSans',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTableRow(Appointment appointment, int index) {
    final isEven = index % 2 == 0;
    final isPaid = appointment.paymentStatus.toLowerCase() == 'paid';
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isPaid
            ? const Color(0xFFE8F5E9) // Light green for paid
            : (isEven ? Colors.white : Colors.grey.shade50),
      ),
      child: Row(
        children: [
          // Patient Name with Avatar
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFE53935), // Red background
                  child: Text(
                    appointment.serialNumber.toString(),
                    style: const TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.patientName,
                        style: const TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        appointment.phone,
                        style: TextStyle(
                          fontFamily: 'ProductSans',
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // PID (Patient ID)
          Expanded(
            flex: 2,
            child: Text(
              _enrichedPids[appointment.id] ?? appointment.patientPid ?? '-',
              style: TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 13,
                color: (_enrichedPids[appointment.id] != null || appointment.hasPatientRecord)
                    ? const Color(0xFF2196F3) 
                    : Colors.grey.shade500,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Gender
          Expanded(
            flex: 1,
            child: Text(
              appointment.gender,
              style: const TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 13,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          // Age
          Expanded(
            flex: 1,
            child: Text(
              appointment.age.toString(),
              style: const TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 13,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          // Date
          Expanded(
            flex: 2,
            child: Text(
              DateFormat('MM/dd/yyyy').format(DateTime.parse(appointment.appointmentDate)),
              style: const TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 13,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          // Time
          Expanded(
            flex: 1,
            child: Text(
              appointment.appointmentTime,
              style: const TextStyle(
                fontFamily: 'ProductSans',
                fontSize: 13,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
          // Payment Status
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: appointment.paymentStatus.toLowerCase() == 'paid'
                      ? const Color(0xFF4CAF50).withOpacity(0.1)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  appointment.paymentStatus,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'ProductSans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: appointment.paymentStatus.toLowerCase() == 'paid'
                        ? const Color(0xFF4CAF50)
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          ),
          // Price
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: () => _showPriceEditor(context, appointment),
              child: Row(
                children: [
                  Text(
                    '৳${appointment.paymentAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontFamily: 'ProductSans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.edit, size: 14, color: Colors.blue.shade400),
                ],
              ),
            ),
          ),
          // Status
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () => _showStatusMenu(context, appointment),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(appointment.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      appointment.status,
                      style: TextStyle(
                        fontFamily: 'ProductSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(appointment.status),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                      color: _getStatusColor(appointment.status),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Actions
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // View
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.visibility, color: Color(0xFF2196F3), size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'View',
                ),
                const SizedBox(width: 8),
                // Edit
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, color: Color(0xFF2196F3), size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Edit',
                ),
                const SizedBox(width: 8),
                // RX (Prescription)
                IconButton(
                  onPressed: () {
                    if (widget.onCreateRx != null) {
                      widget.onCreateRx!(
                        patientId: _enrichedPids[appointment.id] ?? appointment.patientPid ?? '',
                        patientName: appointment.patientName,
                        patientAge: appointment.age.toString(),
                        patientGender: appointment.gender,
                        patientPhone: appointment.phone,
                      );
                    }
                  },
                  icon: const Icon(Icons.medication, color: Color(0xFFFE3001), size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Prescription',
                ),
                const SizedBox(width: 8),
                // Complete (Mark as Paid)
                IconButton(
                  onPressed: () => _markAsPaid(appointment),
                  icon: const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'Mark as Paid',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPriceEditor(BuildContext context, Appointment appointment) {
    final TextEditingController priceController = TextEditingController(
      text: appointment.paymentAmount.toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Price'),
        content: TextField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Price (BDT)',
            prefixText: '৳',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              // TODO: Update price via API
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Price updated successfully')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showStatusMenu(BuildContext context, Appointment appointment) {
    final statuses = ['Scheduled', 'Completed', 'Cancelled'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses.map((status) {
            return ListTile(
              leading: Icon(
                Icons.circle,
                color: _getStatusColor(status),
                size: 12,
              ),
              title: Text(status),
              onTap: () async {
                Navigator.pop(context);
                await _updateStatus(appointment.id, status);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _updateStatus(int id, String status) async {
    try {
      final success = await _appointmentService.updateAppointmentStatus(id, status);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status updated to $status')),
        );
        _loadData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating status: $e')),
      );
    }
  }

  Future<void> _markAsPaid(Appointment appointment) async {
    try {
      final success = await _appointmentService.updatePaymentStatus(
        appointment.id,
        'Paid',
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment status updated to Paid'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        _loadData(); // Reload data to show updated status
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update payment status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildPageButton(int pageNum) {
    final isSelected = pageNum == _currentPage;
    return InkWell(
      onTap: () {
        setState(() {
          _currentPage = pageNum;
        });
        _loadData();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          pageNum.toString(),
          style: TextStyle(
            fontFamily: 'ProductSans',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
