import 'package:flutter/material.dart';
import '../models/task.dart';

/// Item visual de tarefa da lista.
/// Mostra um checkbox, o texto e um botão de remoção.
class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: task.done ? Colors.green.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.done ? Colors.green : Colors.grey.shade300,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 4,
            offset: Offset(0, 3),
            color: Colors.black12,
          )
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: task.done,
            onChanged: (_) => onToggle(),
            activeColor: Colors.green,
          ),
          Expanded(
            child: Text(
              task.title,
              style: TextStyle(
                fontSize: 16,
                decoration:
                    task.done ? TextDecoration.lineThrough : TextDecoration.none,
                color: task.done ? Colors.black54 : Colors.black87,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
