class DateTimeParser {
  final String dateTimeString;
  late String date;

  DateTimeParser(this.dateTimeString){
    this.date = DateTime.parse(dateTimeString).day.toString();
  }

  String getFormattedDate() {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return "${dateTime.day} ${getMonthName(dateTime.month).substring(0, 3)} ${dateTime.year}";
  }
  
  String getMonth(){
    return getMonthName(DateTime.parse(dateTimeString).month);
  }

  String getYear(){
    DateTime dateTime = DateTime.parse(dateTimeString);
    return dateTime.year.toString();
  }
  
  String getFormattedTime() {
    DateTime dateTime = DateTime.parse(dateTimeString);
    int hour = dateTime.hour;
    int minute = dateTime.minute;
    String meridiem = hour < 12 ? "AM" : "PM";
    hour = hour > 12 ? hour - 12 : hour;
    return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $meridiem";
  }

  String getMonthName(int monthNumber) {
    switch (monthNumber) {
      case 1:
        return "Jan";
      case 2:
        return "Feb";
      case 3:
        return "Mar";
      case 4:
        return "Apr";
      case 5:
        return "May";
      case 6:
        return "Jun";
      case 7:
        return "Jul";
      case 8:
        return "Aug";
      case 9:
        return "Sep";
      case 10:
        return "Oct";
      case 11:
        return "Nov";
      case 12:
        return "Dec";
      default:
        return "";
    }
  }

  getWeek(){
    DateTime dateTime = DateTime.parse(dateTimeString);
    int weekNo = dateTime.weekday;

    switch(weekNo){
      case 7:
        return 'Sun';
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
    }
  }
}
