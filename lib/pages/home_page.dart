import 'package:flutter/material.dart';
import '../models/task.dart';
import '../widgets/task_item.dart';

/// Tela principal do aplicativo.
/// Mostra um calendário simples e as tarefas do dia selecionado.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// Mapa que associa uma data (apenas dia/mês/ano) à lista de tarefas.
  final Map<DateTime, List<Task>> _tasksByDay = {};

  late DateTime _selectedDay;
  String _userName = 'Aluno';
  String _userRa = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    _userName = args?['name'] ?? 'Aluno';
    _userRa = args?['ra'] ?? '';

    _selectedDay = _normalizeDate(DateTime.now());
    _ensureListForSelectedDay();
    _sortCurrentDayTasks();
  }

  /// Remove informação de hora/minuto/segundo para trabalhar só com a data.
  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  /// Garante que exista uma lista de tarefas para o dia selecionado.
  void _ensureListForSelectedDay() {
    _tasksByDay.putIfAbsent(_selectedDay, () => []);
  }

  /// Ordena as tarefas do dia:
  /// 1) Tarefas pendentes primeiro
  /// 2) Tarefas concluídas depois
  /// 3) Ambas em ordem alfabética.
  void _sortCurrentDayTasks() {
    final list = _tasksByDay[_selectedDay];
    if (list == null) return;

    list.sort((a, b) {
      if (a.done != b.done) {
        return a.done ? 1 : -1;
      }
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    });
  }

  /// Abre um diálogo para adicionar uma nova tarefa ao dia selecionado.
  Future<void> _addTask() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nova tarefa'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Digite a descrição da tarefa',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = controller.text.trim();
                if (text.isNotEmpty) {
                  Navigator.pop(context, text);
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _ensureListForSelectedDay();
        _tasksByDay[_selectedDay]!.add(Task(title: result));
        _sortCurrentDayTasks();
      });
    }
  }

  /// Alterna o estado de conclusão da tarefa (pendente/concluída).
  void _toggleTask(Task task) {
    setState(() {
      task.done = !task.done;
      _sortCurrentDayTasks();
    });
  }

  /// Remove a tarefa da lista do dia.
  void _removeTask(int index) {
    setState(() {
      _tasksByDay[_selectedDay]!.removeAt(index);
      _sortCurrentDayTasks();
    });
  }

  /// Atualiza o dia selecionado ao clicar em outra data no calendário.
  void _changeDay(DateTime day) {
    setState(() {
      _selectedDay = _normalizeDate(day);
      _ensureListForSelectedDay();
      _sortCurrentDayTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFFFF4081);
    const bg = Color(0xFFF2F2F7);

    final tasks = _tasksByDay[_selectedDay] ?? [];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 4,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: primary),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo, $_userName!',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                if (_userRa.isNotEmpty)
                  Text(
                    'MEU RA: $_userRa',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
              ],
            ),
          ],
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.star, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _CalendarCard(
              selectedDay: _selectedDay,
              onSelectDay: _changeDay,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: const [
                Text(
                  'Planejamento de hoje',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: tasks.isEmpty
                  ? const Center(
                      child: Text(
                        'Você ainda não adicionou tarefas para este dia.\nToque no botão + para começar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54),
                      ),
                    )
                  : ListView.separated(
                      itemCount: tasks.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return TaskItem(
                          task: task,
                          onToggle: () => _toggleTask(task),
                          onDelete: () => _removeTask(index),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 4),
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Organize seu dia e alcance mais! 💪',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ),
        ],
      ),
      floatingActionButton: AnimatedScale(
        scale: 1.0,
        duration: const Duration(milliseconds: 250),
        child: FloatingActionButton(
          onPressed: _addTask,
          backgroundColor: primary,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}

/// Cartão que contém o calendário mensal simplificado, desenhado manualmente.
class _CalendarCard extends StatelessWidget {
  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelectDay;

  const _CalendarCard({
    required this.selectedDay,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    final month = selectedDay.month;
    final year = selectedDay.year;

    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startWeekday = firstDayOfMonth.weekday; // 1 = Monday

    final List<Widget> dayWidgets = [];

    const weekDays = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

    // Cabeçalho com as letras dos dias da semana.
    dayWidgets.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weekDays
            .map(
              (d) => Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );

    int currentDay = 1;
    int weekdayIndex = 1;

    // Criação das linhas com os dias do mês.
    while (currentDay <= daysInMonth) {
      final rowChildren = <Widget>[];

      for (int i = 1; i <= 7; i++) {
        if (weekdayIndex < startWeekday || currentDay > daysInMonth) {
          rowChildren.add(const Expanded(child: SizedBox(height: 40)));
        } else {
          final date = DateTime(year, month, currentDay);
          final isSelected =
              date.year == selectedDay.year &&
              date.month == selectedDay.month &&
              date.day == selectedDay.day;

          rowChildren.add(
            Expanded(
              child: GestureDetector(
                onTap: () => onSelectDay(date),
                child: Container(
                  height: 40,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFF4081)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF4081)
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$currentDay',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
          currentDay++;
        }
        weekdayIndex++;
      }

      dayWidgets.add(const SizedBox(height: 4));
      dayWidgets.add(Row(children: rowChildren));
    }

    final monthNames = [
      '',
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            offset: Offset(0, 4),
            color: Colors.black12,
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            '${monthNames[month]} de $year',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Dia selecionado: '
            '${selectedDay.day.toString().padLeft(2, '0')}/'
            '${selectedDay.month.toString().padLeft(2, '0')}/'
            '${selectedDay.year}',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          ...dayWidgets,
        ],
      ),
    );
  }
}
