import 'package:get/get.dart';

class CalendarController extends GetxController {
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<DateTime> currentMonth = DateTime.now().obs;

  void selectDate(DateTime date) => selectedDate.value = date;

  void previousMonth() {
    final d = currentMonth.value;
    currentMonth.value = DateTime(d.year, d.month - 1);
  }

  void nextMonth() {
    final d = currentMonth.value;
    currentMonth.value = DateTime(d.year, d.month + 1);
  }

  bool isSelected(DateTime date) =>
      date.year == selectedDate.value.year &&
      date.month == selectedDate.value.month &&
      date.day == selectedDate.value.day;

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}
