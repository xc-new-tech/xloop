import 'package:intl/intl.dart';

/// 日期时间工具类
class DateUtils {
  // 私有构造函数，防止实例化
  DateUtils._();

  // 常用日期格式
  static const String _defaultDateFormat = 'yyyy-MM-dd';
  static const String _defaultTimeFormat = 'HH:mm:ss';
  static const String _defaultDateTimeFormat = 'yyyy-MM-dd HH:mm:ss';
  static const String _displayDateFormat = 'yyyy年MM月dd日';
  static const String _displayTimeFormat = 'HH:mm';
  static const String _displayDateTimeFormat = 'yyyy年MM月dd日 HH:mm';
  static const String _isoFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";

  /// 获取当前时间戳（毫秒）
  static int get currentTimestamp => DateTime.now().millisecondsSinceEpoch;

  /// 获取当前时间戳（秒）
  static int get currentTimestampSeconds => 
      DateTime.now().millisecondsSinceEpoch ~/ 1000;

  /// 格式化日期时间为字符串
  static String formatDateTime(
    DateTime dateTime, {
    String format = _defaultDateTimeFormat,
  }) {
    try {
      return DateFormat(format).format(dateTime);
    } catch (e) {
      return dateTime.toString();
    }
  }

  /// 格式化日期为字符串
  static String formatDate(
    DateTime dateTime, {
    String format = _defaultDateFormat,
  }) {
    try {
      return DateFormat(format).format(dateTime);
    } catch (e) {
      return dateTime.toString().split(' ')[0];
    }
  }

  /// 格式化时间为字符串
  static String formatTime(
    DateTime dateTime, {
    String format = _defaultTimeFormat,
  }) {
    try {
      return DateFormat(format).format(dateTime);
    } catch (e) {
      final timeStr = dateTime.toString().split(' ');
      return timeStr.length > 1 ? timeStr[1].split('.')[0] : '00:00:00';
    }
  }

  /// 解析字符串为DateTime
  static DateTime? parseDateTime(
    String dateTimeStr, {
    String? format,
  }) {
    try {
      if (format != null) {
        return DateFormat(format).parse(dateTimeStr);
      }
      
      // 尝试常见格式
      final formats = [
        _isoFormat,
        _defaultDateTimeFormat,
        _defaultDateFormat,
        'yyyy-MM-ddTHH:mm:ss',
        'yyyy/MM/dd HH:mm:ss',
        'yyyy/MM/dd',
        'dd/MM/yyyy',
        'MM/dd/yyyy',
      ];

      for (final fmt in formats) {
        try {
          return DateFormat(fmt).parse(dateTimeStr);
        } catch (_) {
          continue;
        }
      }

      // 最后尝试DateTime.parse
      return DateTime.parse(dateTimeStr);
    } catch (e) {
      return null;
    }
  }

  /// 格式化为显示友好的日期时间
  static String formatForDisplay(DateTime dateTime) {
    return formatDateTime(dateTime, format: _displayDateTimeFormat);
  }

  /// 格式化为显示友好的日期
  static String formatDateForDisplay(DateTime dateTime) {
    return formatDate(dateTime, format: _displayDateFormat);
  }

  /// 格式化为显示友好的时间
  static String formatTimeForDisplay(DateTime dateTime) {
    return formatTime(dateTime, format: _displayTimeFormat);
  }

  /// 格式化为ISO 8601格式
  static String formatToIso(DateTime dateTime) {
    return dateTime.toUtc().toIso8601String();
  }

  /// 从时间戳创建DateTime（毫秒）
  static DateTime fromTimestamp(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// 从时间戳创建DateTime（秒）
  static DateTime fromTimestampSeconds(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  }

  /// 获取相对时间描述（如：刚刚、5分钟前、2小时前等）
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.isNegative) {
      return '未来时间';
    }

    if (difference.inSeconds < 60) {
      return '刚刚';
    }

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    }

    if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    }

    if (difference.inDays < 30) {
      final weeks = difference.inDays ~/ 7;
      return '${weeks}周前';
    }

    if (difference.inDays < 365) {
      final months = difference.inDays ~/ 30;
      return '${months}个月前';
    }

    final years = difference.inDays ~/ 365;
    return '${years}年前';
  }

  /// 获取智能时间描述
  static String getSmartTimeDescription(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    
    final targetDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (targetDate == today) {
      return '今天 ${formatTimeForDisplay(dateTime)}';
    } else if (targetDate == yesterday) {
      return '昨天 ${formatTimeForDisplay(dateTime)}';
    } else if (targetDate == tomorrow) {
      return '明天 ${formatTimeForDisplay(dateTime)}';
    } else if (dateTime.year == now.year) {
      return DateFormat('MM月dd日 HH:mm').format(dateTime);
    } else {
      return formatForDisplay(dateTime);
    }
  }

  /// 检查是否为今天
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
           dateTime.month == now.month &&
           dateTime.day == now.day;
  }

  /// 检查是否为昨天
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
           dateTime.month == yesterday.month &&
           dateTime.day == yesterday.day;
  }

  /// 检查是否为明天
  static bool isTomorrow(DateTime dateTime) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dateTime.year == tomorrow.year &&
           dateTime.month == tomorrow.month &&
           dateTime.day == tomorrow.day;
  }

  /// 检查是否为本周
  static bool isThisWeek(DateTime dateTime) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return dateTime.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           dateTime.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// 获取月份的开始日期
  static DateTime getStartOfMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, 1);
  }

  /// 获取月份的结束日期
  static DateTime getEndOfMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month + 1, 0, 23, 59, 59, 999);
  }

  /// 获取一周的开始日期（周一）
  static DateTime getStartOfWeek(DateTime dateTime) {
    final weekday = dateTime.weekday;
    return dateTime.subtract(Duration(days: weekday - 1));
  }

  /// 获取一周的结束日期（周日）
  static DateTime getEndOfWeek(DateTime dateTime) {
    final weekday = dateTime.weekday;
    return dateTime.add(Duration(days: 7 - weekday, hours: 23, minutes: 59, seconds: 59, milliseconds: 999));
  }

  /// 获取一天的开始时间
  static DateTime getStartOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  /// 获取一天的结束时间
  static DateTime getEndOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59, 999);
  }

  /// 计算两个日期之间的天数差
  static int daysBetween(DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day);
    return endDate.difference(startDate).inDays;
  }

  /// 获取年龄
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }

  /// 添加工作日（跳过周末）
  static DateTime addBusinessDays(DateTime date, int days) {
    DateTime result = date;
    int addedDays = 0;
    
    while (addedDays < days) {
      result = result.add(const Duration(days: 1));
      // 跳过周末（Saturday: 6, Sunday: 7）
      if (result.weekday != DateTime.saturday && result.weekday != DateTime.sunday) {
        addedDays++;
      }
    }
    
    return result;
  }

  /// 检查是否为工作日
  static bool isBusinessDay(DateTime date) {
    return date.weekday != DateTime.saturday && date.weekday != DateTime.sunday;
  }

  /// 获取时区偏移字符串
  static String getTimezoneOffset(DateTime dateTime) {
    final offset = dateTime.timeZoneOffset;
    final hours = offset.inHours.abs();
    final minutes = (offset.inMinutes.abs() % 60);
    final sign = offset.isNegative ? '-' : '+';
    
    return '$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }
} 