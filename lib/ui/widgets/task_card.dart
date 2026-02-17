import 'package:carpe_diem/data/models/label.dart';
import 'package:carpe_diem/providers/label_provider.dart';
import 'package:carpe_diem/ui/widgets/context_menu/label_chip.dart';
import 'package:flutter/material.dart';
import 'package:carpe_diem/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:carpe_diem/data/models/task.dart';
import 'package:carpe_diem/data/models/project.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  final Project? project;
  final VoidCallback onToggle;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool isOverdue;
  final bool selectionMode;
  final bool isSelected;
  final void Function(Offset localPosition, RenderBox renderBox)? onContextMenu;

  const TaskCard({
    super.key,
    required this.task,
    this.project,
    required this.onToggle,
    required this.onTap,
    this.trailing,
    this.isOverdue = false,
    this.selectionMode = false,
    this.isSelected = false,
    this.onContextMenu,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isPending = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 5));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _completeTask();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleToggle() {
    if (widget.selectionMode) {
      widget.onToggle();
      return;
    }

    if (widget.task.isCompleted) {
      // Undo immediately
      widget.onToggle();
    } else {
      if (_isPending) {
        // Cancel pending completion
        _controller.reset();
        setState(() => _isPending = false);
      } else {
        // Start pending completion
        setState(() => _isPending = true);
        _controller.forward();
      }
    }
  }

  void _completeTask() {
    if (mounted) {
      setState(() => _isPending = false);
      _controller.reset();
      widget.onToggle();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          foregroundPainter: _isPending
              ? _ProgressPainter(progress: _controller.value, color: AppColors.accent, width: 3.0, borderRadius: 12.0)
              : null,
          child: child,
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: InkWell(
          onTap: widget.onTap,
          onSecondaryTapDown: widget.onContextMenu != null
              ? (details) => widget.onContextMenu!(details.localPosition, context.findRenderObject() as RenderBox)
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: widget.project?.color != null
                  ? LinearGradient(
                      colors: [AppColors.surface, widget.project!.color],
                      begin: Alignment.center,
                      end: Alignment.centerRight,
                    )
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _priorityIndicator(),
                  const SizedBox(width: 8),
                  Checkbox(
                    value: widget.selectionMode ? widget.isSelected : (widget.task.isCompleted || _isPending),
                    onChanged: (_) => _handleToggle(),
                    fillColor: _isPending ? WidgetStateProperty.all(AppColors.accent.withValues(alpha: 0.5)) : null,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.task.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            decoration: (!widget.selectionMode && (widget.task.isCompleted || _isPending))
                                ? TextDecoration.lineThrough
                                : null,
                            color: ((widget.task.isCompleted || _isPending) && !widget.selectionMode)
                                ? AppColors.textSecondary
                                : AppColors.text,
                          ),
                        ),
                        if (widget.task.description != null && widget.task.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              widget.task.description!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ),
                        if (widget.project != null || widget.isOverdue) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              if (widget.isOverdue && !widget.task.isCompleted && !_isPending) _overdueChip(),
                              if (widget.project != null) _projectChip(),
                              if (widget.project != null) ..._getLabels(context),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (widget.trailing != null) widget.trailing!,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _priorityIndicator() {
    return Container(
      width: 6,
      height: 40,
      decoration: BoxDecoration(color: widget.task.priority.color, borderRadius: BorderRadius.circular(2)),
    );
  }

  Widget _projectChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: widget.project!.color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(widget.project!.name, style: TextStyle(fontSize: 11, color: AppColors.text)),
    );
  }

  Widget _overdueChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(4)),
      child: const Text('Overdue', style: TextStyle(fontSize: 11, color: AppColors.error)),
    );
  }

  List<Widget> _getLabels(BuildContext context) {
    final labelProvider = context.watch<LabelProvider>();
    final labels = widget.project!.labelIds.map((id) => labelProvider.getById(id)).whereType<Label>().toList();

    return labels.map((label) {
      return Padding(
        padding: const EdgeInsets.only(left: 4),
        child: LabelChip(label: label),
      );
    }).toList();
  }
}

class _ProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double width;
  final double borderRadius;

  _ProgressPainter({required this.progress, required this.color, required this.width, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // We want to animate the stroke drawing path
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics().first;
    final extractPath = metrics.extractPath(0.0, metrics.length * progress);

    canvas.drawPath(extractPath, paint);
  }

  @override
  bool shouldRepaint(covariant _ProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
