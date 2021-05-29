import 'dart:ui';

class Time {
  final int hour;
  final int minute;
  final int second;
  final int millisecond;
  final int microsecond;

  const Time({
    required this.hour,
    required this.minute,
    required this.second,
    this.millisecond = 0,
    this.microsecond = 0,
  });

  Time.fromDateTime(DateTime dateTime)
      : hour = dateTime.hour,
        minute = dateTime.minute,
        second = dateTime.second,
        millisecond = dateTime.millisecond,
        microsecond = dateTime.microsecond;

  DateTime dateTime({Date? date}) => DateTime(
        date?.year ?? 1970,
        date?.month ?? 1,
        date?.day ?? 1,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      );

  Time copyWith({
    int? hour,
    int? minute,
    int? second,
    int? millisecond,
    int? microsecond,
  }) {
    return Time(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      second: second ?? this.second,
      millisecond: millisecond ?? this.millisecond,
      microsecond: microsecond ?? this.microsecond,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'minute': minute,
      'second': second,
      'millisecond': millisecond,
      'microsecond': microsecond,
    };
  }

  factory Time.fromJson(Map<String, dynamic> map) {
    return Time(
      hour: map['hour'] as int,
      minute: map['minute'] as int,
      second: map['second'] as int,
      millisecond: map['millisecond'] as int,
      microsecond: map['microsecond'] as int,
    );
  }

  @override
  String toString() {
    return 'Time(hour: $hour, minute: $minute, second: $second, millisecond: $millisecond, microsecond: $microsecond)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Time &&
        other.hour == hour &&
        other.minute == minute &&
        other.second == second &&
        other.millisecond == millisecond &&
        other.microsecond == microsecond;
  }

  @override
  int get hashCode {
    return hashValues(
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }
}

class Date {
  final int year;
  final int month;
  final int day;

  const Date({
    required this.year,
    required this.month,
    required this.day,
  });

  Date.fromDateTime(DateTime dateTime)
      : year = dateTime.year,
        month = dateTime.month,
        day = dateTime.day;

  DateTime dateTime({Time? time}) => DateTime(
        year,
        month,
        day,
        time?.hour ?? 0,
        time?.minute ?? 0,
        time?.second ?? 0,
        time?.millisecond ?? 0,
        time?.microsecond ?? 0,
      );

  Date copyWith({
    int? year,
    int? month,
    int? day,
  }) {
    return Date(
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'year': year,
      'month': month,
      'day': day,
    };
  }

  factory Date.fromJson(Map<String, dynamic> map) {
    return Date(
      year: map['year'] as int,
      month: map['month'] as int,
      day: map['day'] as int,
    );
  }

  @override
  String toString() => 'Date(year: $year, month: $month, day: $day)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Date &&
        other.year == year &&
        other.month == month &&
        other.day == day;
  }

  @override
  int get hashCode => hashValues(year, month, day);
}
