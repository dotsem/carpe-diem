import 'package:carpe_diem/ui/dialogs/common/custom_date_picker_dialog.dart';
import 'package:flutter/material.dart';

class DatePickerButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime?> onChanged;

  const DatePickerButton({
    super.key,
    required this.label,
    required this.date,
    this.firstDate,
    this.lastDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveFirstDate = firstDate ?? DateTime(2025); // who whats to travel in time?
    final effectiveLastDate = lastDate ?? DateTime(2100);

    return InkWell(
      onTap: () async {
        DateTime initialDate = date ?? DateTime.now();

        if (initialDate.isBefore(effectiveFirstDate)) {
          initialDate = effectiveFirstDate;
        } else if (initialDate.isAfter(effectiveLastDate)) {
          initialDate = effectiveLastDate;
        }

        final picked = await showDialog<DateTime>(
          context: context,
          builder: (context) => CustomDatePickerDialog(
            initialDate: initialDate,
            firstDate: effectiveFirstDate,
            lastDate: effectiveLastDate,
          ),
        );
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Text(
              date != null ? '${date!.day}/${date!.month}/${date!.year}' : label,
              style: TextStyle(
                color: date != null
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            if (date != null) ...[
              const Spacer(),
              GestureDetector(
                onTap: () => onChanged(null),
                child: Icon(Icons.close, size: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
