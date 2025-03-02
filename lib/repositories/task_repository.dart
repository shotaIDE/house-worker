import 'package:house_worker/models/task.dart';
import 'package:house_worker/repositories/base_repository.dart';
import 'package:isar/isar.dart';

class TaskRepository extends BaseRepository<Task> {
  TaskRepository(super.isar);

  Future<List<Task>> getIncompleteTasks() async {
    return await collection
        .where()
        .isCompletedEqualTo(false)
        .sortByPriorityDesc()
        .findAll();
  }

  Future<List<Task>> getCompletedTasks() async {
    return await collection
        .where()
        .isCompletedEqualTo(true)
        .sortByCompletedAtDesc()
        .findAll();
  }

  Future<List<Task>> getTasksByUser(String userId) async {
    return await collection
        .where()
        .createdByEqualTo(userId)
        .or()
        .completedByEqualTo(userId)
        .findAll();
  }

  Future<List<Task>> getSharedTasks() async {
    return await collection
        .where()
        .isSharedEqualTo(true)
        .sortByPriorityDesc()
        .findAll();
  }

  Future<List<Task>> getRecurringTasks() async {
    return await collection
        .where()
        .isRecurringEqualTo(true)
        .sortByPriorityDesc()
        .findAll();
  }

  Future<void> completeTask(Task task, String userId) async {
    await isar.writeTxn(() async {
      task.isCompleted = true;
      task.completedAt = DateTime.now();
      task.completedBy = userId;
      await collection.put(task);
    });
  }
}
