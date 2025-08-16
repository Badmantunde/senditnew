import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterModalContent extends StatefulWidget {
  const FilterModalContent({super.key});

  @override
  State<FilterModalContent> createState() => _FilterModalContentState();
}

class _FilterModalContentState extends State<FilterModalContent> {
  DateTime? startDate;
  DateTime? endDate;
  String? selectedStatus;

  final List<String> statuses = ['Pending', 'Completed', 'Failed'];

  Future<void> pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) startDate = picked;
        else endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter by',
                style: GoogleFonts.dmSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff1E1E1E),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xffF1F1F3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 20),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Date Pickers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Start Date
              GestureDetector(
                  onTap: () => pickDate(true),
                  child: Container(
                    width: 165,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xffF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          startDate != null
                              ? '${startDate!.toLocal()}'.split(' ')[0]
                              : '-Select date-',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.grey.shade600, size: 20),
                      ],
                    ),
                  ),
                ),

              const SizedBox(width: 12),
              // End Date
              
              GestureDetector(
                  onTap: () => pickDate(true),
                  child: Container(
                    width: 165,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xffF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          startDate != null
                              ? '${startDate!.toLocal()}'.split(' ')[0]
                              : '-Select date-',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.grey.shade600, size: 20),
                      ],
                    ),
                  ),
                ),

            ],
          ),

          const SizedBox(height: 16),

          // Status Dropdown
          Text('Status', style: GoogleFonts.dmSans(fontSize: 14)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xffF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedStatus,
                hint: const Text('-Select status-'),
                items: statuses.map((status) {
                  return DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedStatus = value),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // You can apply filters here
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffF28D35),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Apply',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
