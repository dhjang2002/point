
// ignore_for_file: file_names
import 'package:point/common/buttonSingle.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarDaySelect extends StatefulWidget {
  const CalendarDaySelect({Key? key}) : super(key: key);

  @override
  State<CalendarDaySelect> createState() => _CalendarDaySelectState();
}

class _CalendarDaySelectState extends State<CalendarDaySelect> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  final DateTime _today = DateTime.now();
  DateTime  _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<DateTime> _selTimeList = <DateTime>[];

  // bool _bDateSet = false;
  // bool _bTimeSet = false;
  bool _bDirty = false;
  bool _btnEnable = false;

  String _timeText = "";
  String _dateText = "";

  void _validate() {
    setState((){
      _btnEnable = (_bDirty && _timeText.isNotEmpty && _dateText.isNotEmpty);
    });
  }
  @override
  void initState() {
    setState((){

    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("일정을 선택해 주세요"),
        automaticallyImplyLeading: false,
        actions: [
          Visibility(
            visible: true,
            child: IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 32,
                ),
                onPressed: () async {
                  _doClose();
                }),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return SizedBox(
      height: MediaQuery.of(context).size.height - 80,
      child: Stack(
        children: [

          // content
          Positioned(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.only(left:5, right: 5),
                    child: TableCalendar(
                      locale: 'ko-KR',
                      rowHeight:44,
                      firstDay: _today,
                      lastDay: DateTime.utc(_today.year+1, _today.month, _today.day),
                      focusedDay: _focusedDay,
                      headerVisible: true,
                      calendarFormat: _calendarFormat,
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        weekendTextStyle: const TextStyle().copyWith(color: Colors.red),
                        holidayTextStyle: const TextStyle().copyWith(color: Colors.blue[800]),
                        selectedDecoration : const BoxDecoration(color: Color(0xFFF6C443), shape: BoxShape.circle),
                        todayDecoration : const BoxDecoration(color: Color(0xFF1A4C97), shape: BoxShape.circle,),
                      ),

                      headerStyle: const HeaderStyle(
                        //headerMargin: EdgeInsets.only(left: 0, top: 0, right: 0, bottom: 0),
                        titleCentered: false,
                        formatButtonVisible: false,
                        leftChevronIcon: Icon(Icons.arrow_left),
                        rightChevronIcon: Icon(Icons.arrow_right),
                        titleTextStyle: TextStyle(fontSize: 18.0),
                      ),

                      selectedDayPredicate: (day) { return isSameDay(_selectedDay, day);},
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _bDirty = true;
                          _selectedDay = selectedDay;
                          _focusedDay  = focusedDay;
                        });
                        _validate();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: ButtonSingle(
                    text: '초기화',
                    enable: true,
                    visible: true,
                    enableTextColor: Colors.black,
                    disableTextColor: Colors.black,
                    enableColor: const Color(0xFFF6C443),
                    disableColor: const Color(0xFFF6C443),
                    onClick: () {
                      setState(() {
                        _bDirty = false;
                        _btnEnable = false;
                        _selectedDay = null;
                        _timeText = "";
                        _dateText = "";
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 7,
                  child: ButtonSingle(
                    text: '일정 적용하기',
                    enable: _btnEnable,
                    visible: true,
                    enableTextColor: Colors.white,
                    disableTextColor: const Color(0xFFA9A9B1),
                    enableColor: const Color(0xFF124C97),
                    disableColor: const Color(0xFFEEEEF0),
                    onClick: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _doClose() {
    Navigator.pop(context);
  }
}
