import 'package:carpe_diem/data/models/task.dart';
import 'package:carpe_diem/data/models/task_hierarchy_node.dart';

class TaskHierarchyUtils {
  static List<TaskHierarchyNode> buildHierarchy(List<Task> categoryTasks, {Map<String, Task>? allTasks}) {
    final idSet = categoryTasks.map((t) => t.id).toSet();
    final childrenMap = <String, List<Task>>{};
    final roots = <TaskHierarchyNode>[];

    final addedBlockers = <String>{};
    for (final task in categoryTasks) {
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
    void addNode(TaskHierarchyNode node) {
      result.add(node);

      String? id;
      if (node is TaskNode) {
        id = node.task.id;
      } else if (node is BlockerIndicatorNode) {
        id = node.blockerId;
      }

      if (id != null) {
        final children = childrenMap[id];
        if (children != null) {
          for (final child in children) {
            addNode(TaskNode(child, node.depth + 1));
          }
        }
      }
    }

    for (final root in roots) {
      // Avoid adding the same task multiple times if it was handled as a child elsewhere
      if (root is TaskNode && result.any((n) => n is TaskNode && n.task.id == root.task.id)) {
        continue;
      }
      addNode(root);
    }
    return result;
  }
}
