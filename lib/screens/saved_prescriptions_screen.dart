import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/saved_prescription.dart';
import '../services/prescription_database_service.dart';
import 'create_prescription_screen.dart';

class SavedPrescriptionsScreen extends StatefulWidget {
  final Function(SavedPrescription)? onViewPrescription;
  
  const SavedPrescriptionsScreen({
    Key? key,
    this.onViewPrescription,
  }) : super(key: key);

  @override
  State<SavedPrescriptionsScreen> createState() => _SavedPrescriptionsScreenState();
}

class _SavedPrescriptionsScreenState extends State<SavedPrescriptionsScreen> {
  final PrescriptionDatabaseService _dbService = PrescriptionDatabaseService();
  final TextEditingController _searchController = TextEditingController();
  List<SavedPrescription> _prescriptions = [];
  List<SavedPrescription> _filteredPrescriptions = [];

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadPrescriptions() {
    setState(() {
      _prescriptions = _dbService.getAllPrescriptions();
      _filteredPrescriptions = _prescriptions;
    });
  }

  void _searchPrescriptions(String query) {
    setState(() {
      _filteredPrescriptions = _dbService.searchByPatientName(query);
    });
  }

  void _deletePrescription(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Prescription'),
        content: const Text('Are you sure you want to delete this prescription?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _dbService.deletePrescription(id);
      _loadPrescriptions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription deleted')),
        );
      }
    }
  }

  void _viewPrescription(SavedPrescription prescription) {
    if (widget.onViewPrescription != null) {
      // Use callback to stay within dashboard
      widget.onViewPrescription!(prescription);
    } else {
      // Fallback: Navigate to new screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CreatePrescriptionScreen(
            patientId: prescription.patientId,
            patientName: prescription.patientName,
            patientAge: prescription.age,
            patientGender: prescription.gender,
            patientPhone: prescription.phone,
          ),
        ),
      ).then((_) => _loadPrescriptions());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(24),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFE3001).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.folder_special,
                        color: Color(0xFFFE3001),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Saved Prescriptions',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'ProductSans',
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          Text(
                            '${_prescriptions.length} prescriptions saved',
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'ProductSans',
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: _searchPrescriptions,
                  decoration: InputDecoration(
                    hintText: 'Search by patient name or ID...',
                    hintStyle: TextStyle(
                      fontFamily: 'ProductSans',
                      color: Colors.grey.shade400,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  ),
                ),
              ],
            ),
          ),

          // Prescriptions List
          Expanded(
            child: _filteredPrescriptions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isEmpty
                              ? 'No saved prescriptions'
                              : 'No prescriptions found',
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchController.text.isEmpty
                              ? 'Saved prescriptions will appear here'
                              : 'Try a different search term',
                          style: TextStyle(
                            fontFamily: 'ProductSans',
                            fontSize: 14,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: _filteredPrescriptions.length,
                    itemBuilder: (context, index) {
                      final prescription = _filteredPrescriptions[index];
                      return _buildPrescriptionCard(prescription);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(SavedPrescription prescription) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _viewPrescription(prescription),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Patient Avatar
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFE3001).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          prescription.patientName[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFE3001),
                            fontFamily: 'ProductSans',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Patient Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prescription.patientName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'ProductSans',
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                'ID: ${prescription.patientId}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'ProductSans',
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${prescription.age} • ${prescription.gender}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'ProductSans',
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Delete Button
                    IconButton(
                      onPressed: () => _deletePrescription(prescription.id),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                // Prescription Details
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoChip(
                        Icons.calendar_today,
                        prescription.formattedDate,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoChip(
                        Icons.access_time,
                        prescription.formattedTime,
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoChip(
                        Icons.medication,
                        '${prescription.medicineCount} medicines',
                        Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'ProductSans',
                color: color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
