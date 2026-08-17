import 'package:crm_flutter/api/response/all_lead_stage_response.dart';
import 'package:crm_flutter/styles/color_palette.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StatusFilterDialog extends StatefulWidget {
  final List<Data> allStages;
  final List<String> initialSelectedIds;

  const StatusFilterDialog({
    super.key,
    required this.allStages,
    required this.initialSelectedIds,
  });

  @override
  State<StatusFilterDialog> createState() => _StatusFilterDialogState();
}

class _StatusFilterDialogState extends State<StatusFilterDialog> {
  late List<String> selectedIds;

  @override
  void initState() {
    super.initState();
    selectedIds = List.from(widget.initialSelectedIds);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter by Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.allStages.map((stage) {
                    final isSelected = selectedIds.contains(stage.sId);
                    return FilterChip(
                      label: Text(stage.name ?? ''),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            selectedIds.add(stage.sId!);
                          } else {
                            selectedIds.remove(stage.sId);
                          }
                        });
                      },
                      selectedColor: ColorConstants.MainPurpleBackground.withOpacity(0.2),
                      checkmarkColor: ColorConstants.MainPurpleBackground,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? ColorConstants.MainPurpleBackground
                            : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        selectedIds.clear();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Clear All'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(result: selectedIds);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstants.MainPurpleBackground,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
