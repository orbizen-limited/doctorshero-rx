import 'package:flutter/material.dart';
import '../services/medicine_database_service.dart';

class MedicineSearchDialog extends StatefulWidget {
  final String searchType; // 'name' or 'generic'
  final Function(MedicineData) onMedicineSelected;

  const MedicineSearchDialog({
    Key? key,
    required this.searchType,
    required this.onMedicineSelected,
  }) : super(key: key);

  @override
  State<MedicineSearchDialog> createState() => _MedicineSearchDialogState();
}

class _MedicineSearchDialogState extends State<MedicineSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  List<MedicineData> _searchResults = [];
  bool _isSearching = false;

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      if (widget.searchType == 'name') {
        _searchResults = MedicineDatabaseService.searchByMedicineName(query);
      } else {
        _searchResults = MedicineDatabaseService.searchByGenericName(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 600,
        height: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.searchType == 'name' ? 'Search Medicine by Name' : 'Search Medicine by Generic',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                    fontFamily: 'ProductSans',
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: const Color(0xFF64748B),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Search Field
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: widget.searchType == 'name' 
                    ? 'Type medicine name (e.g., Napa, Ace)...' 
                    : 'Type generic name (e.g., Paracetamol)...',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFFE3001)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFFFE3001), width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'ProductSans',
              ),
              onChanged: _performSearch,
            ),
            const SizedBox(height: 16),
            
            // Results
            Expanded(
              child: _searchResults.isEmpty
                  ? Center(
                      child: Text(
                        _isSearching 
                            ? 'No results found' 
                            : 'Start typing to search medicines...',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                          fontFamily: 'ProductSans',
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final medicine = _searchResults[index];
                        return InkWell(
                          onTap: () {
                            widget.onMedicineSelected(medicine);
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: index < _searchResults.length - 1
                                      ? const Color(0xFFE2E8F0)
                                      : Colors.transparent,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Medicine Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        medicine.displayName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1E293B),
                                          fontFamily: 'ProductSans',
                                        ),
                                      ),
                                      if (medicine.genericName.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          medicine.genericName,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF64748B),
                                            fontFamily: 'ProductSans',
                                          ),
                                        ),
                                      ],
                                      if (medicine.company.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          medicine.company,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF94A3B8),
                                            fontFamily: 'ProductSans',
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Color(0xFF94A3B8),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
