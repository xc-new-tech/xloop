import 'dart:io';
import 'package:csv/csv.dart';
import '../../domain/entities/import_export_entity.dart';

/// CSV处理服务
class CsvProcessorService {
  final CsvToListConverter _csvConverter = const CsvToListConverter();
  final ListToCsvConverter _listConverter = const ListToCsvConverter();

  /// 读取CSV文件
  Future<List<List<dynamic>>> readCsvFile(File file) async {
    final content = await file.readAsString();
    return _csvConverter.convert(content);
  }

  /// 写入CSV文件
  Future<void> writeCsvFile(File file, List<List<dynamic>> data) async {
    final csvContent = _listConverter.convert(data);
    await file.writeAsString(csvContent);
  }

  /// 解析FAQ CSV数据
  Future<List<FaqImportData>> parseFaqCsv(File file) async {
    final data = await readCsvFile(file);
    if (data.isEmpty) return [];

    // 假设第一行是标题行
    final headers = data.first.map((e) => e.toString().toLowerCase()).toList();
    final rows = data.skip(1).toList();

    final faqs = <FaqImportData>[];
    
    for (final row in rows) {
      if (row.length < 2) continue; // 至少需要问题和答案

      final question = _getValueByHeader(headers, row, ['question', '问题', 'q']);
      final answer = _getValueByHeader(headers, row, ['answer', '答案', 'a']);
      
      if (question.isEmpty || answer.isEmpty) continue;

      final category = _getValueByHeader(headers, row, ['category', '分类', 'cat']);
      final tagsStr = _getValueByHeader(headers, row, ['tags', '标签', 'tag']);
      final priorityStr = _getValueByHeader(headers, row, ['priority', '优先级', 'pri']);
      final isActiveStr = _getValueByHeader(headers, row, ['active', '激活', 'enabled']);

      final tags = tagsStr.isNotEmpty 
          ? tagsStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
          : <String>[];
      
      final priority = int.tryParse(priorityStr) ?? 1;
      final isActive = isActiveStr.toLowerCase() != 'false' && isActiveStr != '0';

      faqs.add(FaqImportData(
        question: question,
        answer: answer,
        category: category.isNotEmpty ? category : null,
        tags: tags,
        priority: priority,
        isActive: isActive,
      ));
    }

    return faqs;
  }

  /// 生成FAQ CSV数据
  Future<void> generateFaqCsv(File file, List<Map<String, dynamic>> faqs) async {
    final headers = ['问题', '答案', '分类', '标签', '优先级', '状态'];
    final rows = <List<dynamic>>[headers];

    for (final faq in faqs) {
      final tags = (faq['tags'] as List<dynamic>?)?.join(', ') ?? '';
      rows.add([
        faq['question'] ?? '',
        faq['answer'] ?? '',
        faq['category'] ?? '',
        tags,
        faq['priority'] ?? 1,
        faq['isActive'] == true ? '激活' : '禁用',
      ]);
    }

    await writeCsvFile(file, rows);
  }

  /// 验证CSV文件格式
  Future<ImportValidationResult> validateCsvFile(File file, DataType dataType) async {
    try {
      final data = await readCsvFile(file);
      
      if (data.isEmpty) {
        return const ImportValidationResult(
          isValid: false,
          errors: ['CSV文件为空'],
        );
      }

      switch (dataType) {
        case DataType.faq:
          return _validateFaqCsv(data);
        default:
          return _validateGenericCsv(data);
      }
    } catch (e) {
      return ImportValidationResult(
        isValid: false,
        errors: ['CSV文件格式错误: ${e.toString()}'],
      );
    }
  }

  /// 验证FAQ CSV格式
  ImportValidationResult _validateFaqCsv(List<List<dynamic>> data) {
    final errors = <String>[];
    final warnings = <String>[];
    int validCount = 0;
    int invalidCount = 0;

    if (data.length < 2) {
      errors.add('CSV文件至少需要包含标题行和一行数据');
      return ImportValidationResult(
        isValid: false,
        errors: errors,
      );
    }

    final headers = data.first.map((e) => e.toString().toLowerCase()).toList();
    
    // 检查必需的列
    final hasQuestion = headers.any((h) => ['question', '问题', 'q'].contains(h));
    final hasAnswer = headers.any((h) => ['answer', '答案', 'a'].contains(h));
    
    if (!hasQuestion) {
      errors.add('缺少问题列（question/问题/q）');
    }
    if (!hasAnswer) {
      errors.add('缺少答案列（answer/答案/a）');
    }

    if (errors.isNotEmpty) {
      return ImportValidationResult(
        isValid: false,
        errors: errors,
      );
    }

    // 验证数据行
    final rows = data.skip(1).toList();
    for (int i = 0; i < rows.length; i++) {
      final row = rows[i];
      final rowNumber = i + 2; // +2 因为跳过了标题行，且行号从1开始

      if (row.length < 2) {
        warnings.add('第${rowNumber}行数据不完整');
        invalidCount++;
        continue;
      }

      final question = _getValueByHeader(headers, row, ['question', '问题', 'q']);
      final answer = _getValueByHeader(headers, row, ['answer', '答案', 'a']);

      if (question.isEmpty) {
        warnings.add('第${rowNumber}行缺少问题');
        invalidCount++;
        continue;
      }

      if (answer.isEmpty) {
        warnings.add('第${rowNumber}行缺少答案');
        invalidCount++;
        continue;
      }

      validCount++;
    }

    return ImportValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
      validItemCount: validCount,
      invalidItemCount: invalidCount,
    );
  }

  /// 验证通用CSV格式
  ImportValidationResult _validateGenericCsv(List<List<dynamic>> data) {
    if (data.length < 2) {
      return const ImportValidationResult(
        isValid: false,
        errors: ['CSV文件至少需要包含标题行和一行数据'],
      );
    }

    return ImportValidationResult(
      isValid: true,
      validItemCount: data.length - 1, // 减去标题行
      invalidItemCount: 0,
    );
  }

  /// 根据标题获取值
  String _getValueByHeader(List<String> headers, List<dynamic> row, List<String> possibleHeaders) {
    for (final header in possibleHeaders) {
      final index = headers.indexOf(header);
      if (index != -1 && index < row.length) {
        return row[index]?.toString().trim() ?? '';
      }
    }
    return '';
  }

  /// 生成CSV模板
  Future<void> generateTemplate(File file, DataType dataType) async {
    List<List<dynamic>> template;

    switch (dataType) {
      case DataType.faq:
        template = [
          ['问题', '答案', '分类', '标签', '优先级', '状态'],
          ['示例问题1', '示例答案1', '常见问题', '标签1,标签2', '1', '激活'],
          ['示例问题2', '示例答案2', '技术支持', '标签3', '2', '激活'],
        ];
        break;
      default:
        template = [
          ['列1', '列2', '列3'],
          ['示例数据1', '示例数据2', '示例数据3'],
        ];
    }

    await writeCsvFile(file, template);
  }
} 