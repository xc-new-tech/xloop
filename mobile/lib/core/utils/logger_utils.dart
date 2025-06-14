import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

/// 日志工具类
class LoggerUtils {
  LoggerUtils._();

  /// 全局Logger实例
  static final Logger logger = Logger(
    printer: _CustomPrinter(),
    filter: _CustomFilter(),
    output: _CustomOutput(),
  );

  /// 记录调试信息
  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// 记录信息
  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// 记录警告
  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// 记录错误
  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// 记录严重错误
  static void wtf(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    logger.f(message, error: error, stackTrace: stackTrace);
  }
}

/// 自定义日志过滤器
class _CustomFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // 在发布模式下只记录警告和错误
    if (kReleaseMode) {
      return event.level.index >= Level.warning.index;
    }
    // 在调试模式下记录所有日志
    return true;
  }
}

/// 自定义日志打印器
class _CustomPrinter extends LogPrinter {
  static final _deviceStackTraceRegex = RegExp(r'#[0-9]+[\s]+(.+) \(([^\s]+)\)');
  static const int _methodCount = 2;
  static const int _errorMethodCount = 8;
  static const int _lineLength = 120;
  static const String _topLeftCorner = '┌';
  static const String _bottomLeftCorner = '└';
  static const String _middleCorner = '├';
  static const String _verticalLine = '│';
  static const String _doubleDivider = "═";
  static const String _singleDivider = "─";

  @override
  List<String> log(LogEvent event) {
    final messageStr = _formatMessage(event.message);
    final errorStr = event.error?.toString();
    final timeStr = DateTime.now().toString();

    final methodCount = event.level == Level.error || event.level == Level.fatal
        ? _errorMethodCount
        : _methodCount;

    final stackTraceStr = event.stackTrace != null
        ? _formatStackTrace(event.stackTrace!, methodCount)
        : null;

    final output = <String>[];

    // 顶部边框
    output.add(_topBorder('[${event.level.name.toUpperCase()}] $timeStr'));

    // 消息内容
    if (messageStr.isNotEmpty) {
      output.addAll(_formatMessage(messageStr).map((line) => '$_verticalLine $line'));
    }

    // 错误信息
    if (errorStr?.isNotEmpty == true) {
      output.add(_middleBorder('ERROR'));
      output.addAll(errorStr!.split('\n').map((line) => '$_verticalLine $line'));
    }

    // 堆栈跟踪
    if (stackTraceStr?.isNotEmpty == true) {
      output.add(_middleBorder('STACK TRACE'));
      output.addAll(stackTraceStr!.map((line) => '$_verticalLine $line'));
    }

    // 底部边框
    output.add(_bottomBorder());

    return output;
  }

  String _topBorder(String label) {
    final leftPadding = (_lineLength - label.length - 2) ~/ 2;
    final rightPadding = _lineLength - label.length - leftPadding - 2;
    return '$_topLeftCorner${_doubleDivider * leftPadding} $label ${_doubleDivider * rightPadding}';
  }

  String _middleBorder(String label) {
    final leftPadding = (_lineLength - label.length - 2) ~/ 2;
    final rightPadding = _lineLength - label.length - leftPadding - 2;
    return '$_middleCorner${_singleDivider * leftPadding} $label ${_singleDivider * rightPadding}';
  }

  String _bottomBorder() {
    return '$_bottomLeftCorner${_singleDivider * (_lineLength - 1)}';
  }

  List<String> _formatMessage(dynamic message) {
    final finalMessage = message.toString();
    if (finalMessage.contains('\n')) {
      return finalMessage.split('\n');
    }
    return _formatStringMessage(finalMessage);
  }

  List<String> _formatStringMessage(String message) {
    final List<String> lines = <String>[];
    final int messageLength = message.length;
    const int maxLineLength = _lineLength - 2; // 减去边框字符

    if (messageLength <= maxLineLength) {
      lines.add(message);
    } else {
      int start = 0;
      while (start < messageLength) {
        int end = start + maxLineLength;
        if (end > messageLength) {
          end = messageLength;
        }
        lines.add(message.substring(start, end));
        start = end;
      }
    }

    return lines;
  }

  List<String> _formatStackTrace(StackTrace stackTrace, int methodCount) {
    final List<String> formatted = <String>[];
    final List<String> lines = stackTrace.toString().split('\n');

    for (int count = 0; count < lines.length && count < methodCount; count++) {
      final String line = lines[count];
      if (line.isEmpty) continue;

      if (line.contains(_deviceStackTraceRegex)) {
        final Match? match = _deviceStackTraceRegex.firstMatch(line);
        if (match != null) {
          formatted.add('${match.group(1)} (${match.group(2)})');
        }
      } else {
        formatted.add(line);
      }
    }

    if (formatted.isEmpty) {
      return <String>['Unable to obtain stack trace.'];
    }

    return formatted;
  }
}

/// 自定义日志输出器
class _CustomOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      if (kDebugMode) {
        print(line);
      }
    }
  }
}

/// 日志级别扩展
extension LogLevelExtension on Level {
  /// 获取日志级别对应的颜色（用于终端输出）
  String get color {
    switch (this) {
      case Level.debug:
        return '\x1B[37m'; // 白色
      case Level.info:
        return '\x1B[36m'; // 青色
      case Level.warning:
        return '\x1B[33m'; // 黄色
      case Level.error:
        return '\x1B[31m'; // 红色
      case Level.fatal:
        return '\x1B[35m'; // 紫色
      default:
        return '\x1B[0m'; // 默认颜色
    }
  }

  /// 重置颜色
  static const String reset = '\x1B[0m';
} 