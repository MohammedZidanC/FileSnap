import 'dart:async';
import 'dart:collection';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TaskStatus { idle, loading, success, error, retrying }

class TaskJob {
  final String id;
  final String name;
  final Future<dynamic> Function() payload;
  final int maxRetries;
  int retryCount = 0;
  TaskStatus status = TaskStatus.idle;
  String? error;

  TaskJob({required this.id, required this.name, required this.payload, this.maxRetries = 5});
}

class TaskQueueNotifier extends Notifier<TaskStatus> {
  final Queue<TaskJob> _queue = Queue<TaskJob>();
  TaskJob? _currentJob;
  double progress = 0.0;

  @override
  TaskStatus build() {
    return TaskStatus.idle;
  }

  void enqueue(TaskJob job) {
    _queue.add(job);
    if (state == TaskStatus.idle || state == TaskStatus.success || state == TaskStatus.error) {
      _processNext();
    }
  }

  Future<void> _processNext() async {
    if (_queue.isEmpty) {
      state = TaskStatus.success;
      return;
    }

    _currentJob = _queue.removeFirst();
    _currentJob!.status = TaskStatus.loading;
    state = TaskStatus.loading;
    progress = 0.1;

    try {
      progress = 0.5; // Artificial progress since isolated heavy lifting hides the real map
      await _currentJob!.payload();
      progress = 1.0;
      _currentJob!.status = TaskStatus.success;
      
      // Auto move to next task
      _processNext();
    } catch (e) {
      if (_currentJob!.retryCount < _currentJob!.maxRetries) {
        _currentJob!.retryCount++;
        _currentJob!.status = TaskStatus.retrying;
        state = TaskStatus.retrying;
        
        // Smart Retry logic: wait a bit
        await Future.delayed(const Duration(seconds: 1));
        
        // put back at top of queue
        _queue.addFirst(_currentJob!);
        _processNext();
      } else {
        _currentJob!.status = TaskStatus.error;
        _currentJob!.error = e.toString();
        state = TaskStatus.error;
      }
    }
  }

  void retryCurrentField() {
    if (_currentJob != null && state == TaskStatus.error) {
      _currentJob!.retryCount = 0;
      _queue.addFirst(_currentJob!);
      _processNext();
    }
  }

  void cancelQueue() {
    _queue.clear();
    _currentJob = null;
    state = TaskStatus.idle;
  }
}

final taskQueueProvider = NotifierProvider<TaskQueueNotifier, TaskStatus>(() {
  return TaskQueueNotifier();
});
