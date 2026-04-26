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
      final blockedById = task.blockedById;
      if (blockedById != null && idSet.contains(blockedById)) {
        childrenMap.putIfAbsent(blockedById, () => []).add(task);
      } else if (blockedById != null && allTasks != null && allTasks.containsKey(blockedById)) {
        final blocker = allTasks[blockedById]!;
        if (!blocker.isCompleted) {
          if (!addedBlockers.contains(blockedById)) {
            roots.add(
              BlockerIndicatorNode(
                blockerId: blocker.id,
                blockerTitle: blocker.title,
                blockedTaskId: task.id,
                depth: 0,
              ),
            );
            addedBlockers.add(blockedById);
          }
          childrenMap.putIfAbsent(blocker.id, () => []).add(task);
        } else {
          roots.add(TaskNode(task, 0));
        }
      } else {
        roots.add(TaskNode(task, 0));
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
