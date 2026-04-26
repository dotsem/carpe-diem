import 'package:carpe_diem/data/models/task.dart';
import 'package:carpe_diem/data/models/task_hierarchy_node.dart';

class TaskHierarchyUtils {
  static List<TaskHierarchyNode> buildHierarchy(List<Task> categoryTasks, {Map<String, Task>? allTasks}) {
    final seenInputIds = <String>{};
    final uniqueCategoryTasks = categoryTasks.where((t) => seenInputIds.add(t.id)).toList();

    final idSet = uniqueCategoryTasks.map((t) => t.id).toSet();
    final childrenMap = <String, List<Task>>{};
    final roots = <TaskHierarchyNode>[];
    final addedBlockers = <String>{};

    for (final task in uniqueCategoryTasks) {
      // Find the ultimate root for this task to "pull up" blockers to the highest priority item's position
      TaskHierarchyNode? ultimateRoot;
      Task currentTask = task;
      final visitedIds = <String>{task.id};

      while (true) {
        final blockedById = currentTask.blockedById;
        if (blockedById == null) {
          ultimateRoot = TaskNode(currentTask, 0);
          break;
        }

        if (idSet.contains(blockedById)) {
          if (!visitedIds.add(blockedById)) {
            // Cycle detected - treat as root
            ultimateRoot = TaskNode(currentTask, 0);
            break;
          }
          currentTask = uniqueCategoryTasks.firstWhere((t) => t.id == blockedById);
          continue;
        }

        if (allTasks != null && allTasks.containsKey(blockedById)) {
          final blocker = allTasks[blockedById]!;
          if (!blocker.isCompleted) {
            ultimateRoot = BlockerIndicatorNode(
              blockerId: blocker.id,
              blockerTitle: blocker.title,
              blockedTaskId: currentTask.id,
              depth: 0,
            );
          } else {
            ultimateRoot = TaskNode(currentTask, 0);
          }
        } else {
          ultimateRoot = TaskNode(currentTask, 0);
        }
        break;
      }

      final logicalId = (ultimateRoot is TaskNode)
          ? ultimateRoot.task.id
          : 'indicator_${(ultimateRoot as BlockerIndicatorNode).blockerId}';

      if (addedBlockers.add(logicalId)) {
        roots.add(ultimateRoot);
      }

      // Ensure every task is mapped for child pulls regardless of whether it was a root
      final blockedById = task.blockedById;
      if (blockedById != null) {
        if (idSet.contains(blockedById)) {
          childrenMap.putIfAbsent(blockedById, () => []).add(task);
        } else if (allTasks != null && allTasks.containsKey(blockedById)) {
          final blocker = allTasks[blockedById]!;
          if (!blocker.isCompleted) {
            childrenMap.putIfAbsent(blocker.id, () => []).add(task);
          }
        }
      }
    }

    final result = <TaskHierarchyNode>[];
    final processedIds = <String>{}; // Track both task IDs and indicator IDs

    void addNode(TaskHierarchyNode node) {
      String? logicalId;
      String? childLookupId;

      if (node is TaskNode) {
        logicalId = node.task.id;
        childLookupId = node.task.id;
      } else if (node is BlockerIndicatorNode) {
        logicalId = 'indicator_${node.blockerId}';
        childLookupId = node.blockerId;
      }

      if (logicalId == null || processedIds.contains(logicalId)) return;

      processedIds.add(logicalId);
      result.add(node);

      if (childLookupId != null) {
        final children = childrenMap[childLookupId];
        if (children != null) {
          for (final child in children) {
            addNode(TaskNode(child, node.depth + 1));
          }
        }
      }
    }

    for (final root in roots) {
      addNode(root);
    }

    return result;
  }
}
