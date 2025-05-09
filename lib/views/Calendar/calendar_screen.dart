import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../../components/base_screen.dart';
import '../../controller/calendar_controller.dart';

class CalendarScreen extends StatefulWidget {
  final String? userId;

  const CalendarScreen({super.key, required this.userId});

  @override
  CalendarScreenState createState() => CalendarScreenState();
}

class CalendarScreenState extends State<CalendarScreen> {
  late CalendarController _controller;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('pt_BR', null);
    _controller = CalendarController(userId: widget.userId!);
    _controller.generateMonths();
    _controller.loadActivities(() {
      setState(() {});
    });
  }

  void _showTaskDialog(List<Map<String, dynamic>> activities, DateTime selectedDate) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Modal",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 350),
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Atividades de ${DateFormat('dd/MM/yyyy').format(selectedDate)}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Color(0xFF4D673F),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (activities.isEmpty)
                        const Text(
                          "Nenhuma atividade encontrada.",
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        )
                      else
                        ...activities.map((activity) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Color(activity['color'] ?? 0xFFCCCCCC),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Transform.scale(
                                  scale: 1.3,
                                  child: Checkbox(
                                    value: activity['completed'] ?? false,
                                    onChanged: null,
                                    activeColor: Colors.white,
                                    checkColor: Colors.black,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    activity['title'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Text(
                                  DateFormat('HH:mm').format(activity['hour']),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4D673F),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          "Fechar",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, _) => SafeArea(
        child: BaseScreen(
          fundo: "principal_fundo.png",
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 15, 0, 0),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Image.asset(
                          'assets/images/icon/arrow_back.png',
                          width: 50,
                          height: 50,
                        ),
                      ),
                    ),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          left: 4,
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Image.asset(
                              'assets/images/cenario/name_app.png',
                              width: 250,
                              color: Colors.white.withOpacity(0.9),
                              colorBlendMode: BlendMode.srcATop,
                            ),
                          ),
                        ),
                        Image.asset(
                          'assets/images/cenario/name_app.png',
                          width: 250,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Visão Mensal',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: _controller.months.length,
                  itemBuilder: (context, index) {
                    DateTime month = _controller.months[index];
                    DateTime now = DateTime.now();
                    bool isCurrentMonth = (month.year == now.year && month.month == now.month);
                    bool isPastMonth = month.isBefore(DateTime(now.year, now.month));

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        border: isCurrentMonth
                            ? Border.all(color: const Color(0xFF4D673F), width: 3)
                            : (isPastMonth ? null : Border.all(color: Colors.black, width: 2)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            '${DateFormat.MMMM('pt_BR').format(month)[0].toUpperCase()}${DateFormat.MMMM('pt_BR').format(month).substring(1)} ${month.year}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6B74A7),
                            ),
                          ),
                          TableCalendar(
                            locale: 'pt_BR',
                            firstDay: DateTime.utc(2020, 1, 1),
                            lastDay: DateTime.utc(2030, 12, 31),
                            focusedDay: month,
                            headerVisible: false,
                            daysOfWeekVisible: true,
                            availableGestures: AvailableGestures.none,
                            calendarStyle: const CalendarStyle(
                              todayDecoration: BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                              ),
                              outsideDaysVisible: false,
                            ),
                            onDaySelected: (selectedDay, _) async {
                              final activities = await _controller.getActivitiesForDay(selectedDay);
                              _showTaskDialog(activities, selectedDay);
                            },
                            calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, day, focusedDay) {
                                DateTime cleanDay = DateTime(day.year, day.month, day.day);
                                Color? color = _controller.dayColors[cleanDay];
                                bool isSameMonth =
                                    focusedDay.month == day.month && focusedDay.year == day.year;
                                DateTime today = DateTime.now();

                                if (!isSameMonth) return const SizedBox.shrink();

                                if (color != null) {
                                  return Container(
                                    margin: const EdgeInsets.all(6.0),
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${day.day}',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  );
                                } else {
                                  bool isPast = cleanDay.isBefore(DateTime(today.year, today.month, today.day));
                                  return Container(
                                    margin: const EdgeInsets.all(6.0),
                                    decoration: BoxDecoration(
                                      color: isPast ? Colors.grey : null,
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${day.day}',
                                      style: TextStyle(color: isPast ? Colors.white : null),
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}