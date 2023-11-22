import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:trade_agent_v2/constant/constant.dart';
import 'package:trade_agent_v2/daos/daos.dart';
import 'package:trade_agent_v2/entity/entity.dart';
import 'package:trade_agent_v2/generated/l10n.dart';
import 'package:trade_agent_v2/utils/app_bar.dart';

class StrategyPage extends StatefulWidget {
  const StrategyPage({required this.db, super.key});
  final Database db;

  @override
  State<StrategyPage> createState() => _StrategyPage();
}

class _StrategyPage extends State<StrategyPage> {
  late Future<List<Strategy>> futureStrategy;
  late Future<Map<String, bool>> alreadyPick;

  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode.toggledOff;
  late final ValueNotifier<List<Event>> _selectedEvents;

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  Map<String, bool> eventCache = {};

  LinkedHashMap<DateTime, List<Event>> kEvents = LinkedHashMap<DateTime, List<Event>>(
    equals: isSameDay,
    hashCode: getHashCode,
  )..addAll({});

  @override
  void initState() {
    super.initState();
    alreadyPick = getAllPickStock();
    futureStrategy = fetchStrategy();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  Future<Map<String, bool>> getAllPickStock() async {
    final result = <String, bool>{};
    final stocks = await PickStockDao(database: widget.db).getAllPickStock();
    for (final stock in stocks) {
      result[stock.stockNum] = true;
    }
    return result;
  }

  List<Event> _getEventsForDay(DateTime day)
      // Implementation example
      =>
      kEvents[day] ?? [];

  List<Event> _getEventsForRange(DateTime start, DateTime end) {
    // Implementation example
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents.value = _getEventsForDay(end);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: trAppbar(
          context,
          S.of(context).strategy,
          widget.db,
        ),
        body: Column(
          children: [
            FutureBuilder<List<Strategy>>(
              future: futureStrategy,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final tmp = snapshot.data!;
                  final result = <DateTime, List<Event>>{};
                  for (final i in tmp) {
                    result[DateTime.parse(i.date!)] = [];
                    for (final s in i.stocks!) {
                      result[DateTime.parse(i.date!)]!.add(Event(s.number!, s.name!));
                    }
                  }
                  kEvents = LinkedHashMap<DateTime, List<Event>>(
                    equals: isSameDay,
                    hashCode: getHashCode,
                  )..addAll(result);
                  return TableCalendar(
                    firstDay: kFirstDay,
                    lastDay: kLastDay,
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    rangeStartDay: _rangeStart,
                    rangeEndDay: _rangeEnd,
                    calendarFormat: _calendarFormat,
                    rangeSelectionMode: _rangeSelectionMode,
                    eventLoader: _getEventsForDay,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                      markerDecoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    onDaySelected: _onDaySelected,
                    onRangeSelected: _onRangeSelected,
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      // No need to call `setState()` here
                      _focusedDay = focusedDay;
                    },
                    // custom
                    headerStyle: const HeaderStyle(
                      leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                      rightChevronIcon: Icon(Icons.chevron_right, color: Colors.black),
                      formatButtonTextStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                      ),
                    ),
                    daysOfWeekHeight: 40,
                  );
                }
                return const Padding(
                  padding: EdgeInsets.all(80),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ValueListenableBuilder<List<Event>>(
                valueListenable: _selectedEvents,
                builder: (context, value, _) {
                  if (value.isEmpty) {
                    return Center(
                      child: Text(
                        S.of(context).no_data,
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: value.length,
                    itemBuilder: (context, index) => Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        onTap: () async {
                          if (eventCache[value[index].stockNum] != null) {
                            return;
                          }
                          final t = PickStock(
                            value[index].stockNum,
                            value[index].stockNum,
                            1,
                            0,
                            0,
                            0,
                          );
                          await PickStockDao(database: widget.db).insertPickStock(t);
                          setState(() {
                            alreadyPick = getAllPickStock();
                          });
                        },
                        title: Text('${value[index].stockNum} ${value[index].stockName}'),
                        trailing: FutureBuilder<Map<String, bool>>(
                          future: alreadyPick,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final tmp = snapshot.data!;
                              eventCache = tmp;
                              if (tmp[value[index].stockNum] != null) {
                                return const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                );
                              }
                            }
                            return const Icon(Icons.add, color: Colors.red);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
}

final kToday = DateTime.now();
final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

int getHashCode(DateTime key) => key.day * 1000000 + key.month * 10000 + key.year;

/// Returns a list of [DateTime] objects from [first] to [last], inclusive.
List<DateTime> daysInRange(DateTime first, DateTime last) {
  final dayCount = last.difference(first).inDays + 1;
  return List.generate(
    dayCount,
    (index) => DateTime.utc(first.year, first.month, first.day + index),
  );
}

List<Widget> generateStockRow(List<Stocks> arr, BuildContext context) {
  final tmp = <Widget>[];
  for (final i in arr) {
    tmp.add(
      SizedBox(
        // height: 15,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Row(
          children: [
            Expanded(
              child: Text(
                i.number!,
              ),
            ),
            Expanded(
              child: Text(
                i.name!,
              ),
            ),
          ],
        ),
      ),
    );
  }
  return tmp;
}

String commaNumber(String n) => n.replaceAllMapped(reg, mathFunc);

RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
String mathFunc(Match match) => '${match[1]},';

Widget generateRow(String columnName, String value) => SizedBox(
      height: 50,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 20),
        child: Flex(
          direction: Axis.horizontal,
          children: [
            Expanded(
              flex: 3,
              child: Text(
                '$columnName: ',
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.left,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                value,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.left,
              ),
            ),
          ],
        ),
      ),
    );

Future<List<Strategy>> fetchStrategy() async {
  final straregyArr = <Strategy>[];
  try {
    final response = await http.get(Uri.parse('$tradeAgentURLPrefix/analyze/reborn'));
    if (response.statusCode == 200) {
      for (final i in jsonDecode(response.body) as List<dynamic>) {
        straregyArr.add(Strategy.fromJson(i as Map<String, dynamic>));
      }
      return straregyArr;
    } else {
      return straregyArr;
    }
  } on Exception {
    return straregyArr;
  }
}
