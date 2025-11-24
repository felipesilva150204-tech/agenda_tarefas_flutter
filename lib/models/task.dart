/// Modelo simples de tarefa.
///
/// [title] representa o texto da tarefa e
/// [done] indica se a tarefa está concluída ou não.
class Task {
  String title;
  bool done;

  Task({
    required this.title,
    this.done = false,
  });
}
