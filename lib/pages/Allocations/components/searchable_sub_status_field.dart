import 'package:crm_flutter/api/response/substatus_lead_stage_response.dart';
import 'package:flutter/material.dart';

class SearchableSubStatusField extends StatefulWidget {
  final List<SubStatusData> subStatuses;
  final String? selectedId;
  final String label;
  final InputDecoration decoration;
  final ValueChanged<String?> onChanged;

  const SearchableSubStatusField({
    super.key,
    required this.subStatuses,
    required this.selectedId,
    required this.label,
    required this.decoration,
    required this.onChanged,
  });

  @override
  State<SearchableSubStatusField> createState() =>
      _SearchableSubStatusFieldState();
}

class _SearchableSubStatusFieldState extends State<SearchableSubStatusField> {
  Future<void> _openSubStatusSearch() async {
    final selectedId = await showDialog<String>(
      context: context,
      builder: (_) => _SubStatusSearchDialog(
        subStatuses: widget.subStatuses,
        selectedId: widget.selectedId,
        label: widget.label,
      ),
    );

    if (mounted && selectedId != null) {
      widget.onChanged(selectedId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedName = widget.subStatuses
        .where((status) => status.id == widget.selectedId)
        .firstOrNull
        ?.name;

    return InkWell(
      onTap: _openSubStatusSearch,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: widget.decoration,
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedName ?? 'Select Sub Status',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selectedName == null
                      ? Theme.of(context).hintColor
                      : null,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}

class _SubStatusSearchDialog extends StatefulWidget {
  final List<SubStatusData> subStatuses;
  final String? selectedId;
  final String label;

  const _SubStatusSearchDialog({
    required this.subStatuses,
    required this.selectedId,
    required this.label,
  });

  @override
  State<_SubStatusSearchDialog> createState() => _SubStatusSearchDialogState();
}

class _SubStatusSearchDialogState extends State<_SubStatusSearchDialog> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filteredStatuses = widget.subStatuses.where((subStatus) {
      return (subStatus.name ?? '').toLowerCase().contains(query);
    }).toList();

    return AlertDialog(
      title: Text(widget.label),
      content: SizedBox(
        width: double.maxFinite,
        height: 360,
        child: Column(
          children: [
            TextField(
              key: const ValueKey('sub-status-search'),
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search sub-status',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                        icon: const Icon(Icons.clear),
                      ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filteredStatuses.isEmpty
                  ? const Center(child: Text('No sub-status found'))
                  : ListView.builder(
                      itemCount: filteredStatuses.length,
                      itemBuilder: (context, index) {
                        final subStatus = filteredStatuses[index];
                        return ListTile(
                          key: ValueKey('sub-status-option-${subStatus.id}'),
                          title: Text(subStatus.name ?? ''),
                          selected: subStatus.id == widget.selectedId,
                          onTap: () => Navigator.of(context).pop(subStatus.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
