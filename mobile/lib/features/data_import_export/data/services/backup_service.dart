import 'dart:io';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/import_export_entity.dart';

/// 备份服务
class BackupService {
  /// 创建完整备份
  Future<File> createFullBackup({
    required String backupName,
    List<DataType>? dataTypes,
  }) async {
    final backupDir = await _getBackupDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final backupFile = File('${backupDir.path}/${backupName}_$timestamp.zip');

    final archive = Archive();

    // 添加各种数据类型到备份
    if (dataTypes == null || dataTypes.contains(DataType.faq)) {
      await _addFaqsToArchive(archive);
    }

    if (dataTypes == null || dataTypes.contains(DataType.knowledgeBase)) {
      await _addKnowledgeBaseToArchive(archive);
    }

    if (dataTypes == null || dataTypes.contains(DataType.documents)) {
      await _addDocumentsToArchive(archive);
    }

    if (dataTypes == null || dataTypes.contains(DataType.conversations)) {
      await _addConversationsToArchive(archive);
    }

    if (dataTypes == null || dataTypes.contains(DataType.userSettings)) {
      await _addUserSettingsToArchive(archive);
    }

    // 添加备份元数据
    await _addBackupMetadata(archive, backupName, dataTypes);

    // 创建ZIP文件
    final zipData = ZipEncoder().encode(archive);
    await backupFile.writeAsBytes(zipData!);

    return backupFile;
  }

  /// 恢复备份
  Future<void> restoreBackup(File backupFile) async {
    final bytes = await backupFile.readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // 读取备份元数据
    final metadata = await _readBackupMetadata(archive);
    
    // 恢复各种数据类型
    for (final file in archive) {
      if (file.isFile) {
        final fileName = file.name;
        final content = file.content as List<int>;

        if (fileName.startsWith('faqs/')) {
          await _restoreFaqs(fileName, content);
        } else if (fileName.startsWith('knowledge_base/')) {
          await _restoreKnowledgeBase(fileName, content);
        } else if (fileName.startsWith('documents/')) {
          await _restoreDocuments(fileName, content);
        } else if (fileName.startsWith('conversations/')) {
          await _restoreConversations(fileName, content);
        } else if (fileName.startsWith('user_settings/')) {
          await _restoreUserSettings(fileName, content);
        }
      }
    }
  }

  /// 验证备份文件
  Future<ImportValidationResult> validateBackupFile(File backupFile) async {
    try {
      final bytes = await backupFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // 检查是否包含备份元数据
      final hasMetadata = archive.any((file) => file.name == 'backup_metadata.json');
      if (!hasMetadata) {
        return const ImportValidationResult(
          isValid: false,
          errors: ['备份文件缺少元数据'],
        );
      }

      // 读取元数据
      final metadata = await _readBackupMetadata(archive);
      
      return ImportValidationResult(
        isValid: true,
        validItemCount: archive.length - 1, // 减去元数据文件
      );
    } catch (e) {
      return ImportValidationResult(
        isValid: false,
        errors: ['备份文件格式错误: ${e.toString()}'],
      );
    }
  }

  /// 获取备份列表
  Future<List<Map<String, dynamic>>> getBackupList() async {
    final backupDir = await _getBackupDirectory();
    final backups = <Map<String, dynamic>>[];

    if (await backupDir.exists()) {
      final files = backupDir.listSync()
          .where((entity) => entity is File && entity.path.endsWith('.zip'))
          .cast<File>()
          .toList();

      for (final file in files) {
        try {
          final stat = await file.stat();
          final fileName = file.path.split('/').last;
          
          backups.add({
            'name': fileName,
            'path': file.path,
            'size': stat.size,
            'created': stat.modified,
          });
        } catch (e) {
          // 忽略无法读取的文件
        }
      }
    }

    // 按创建时间排序
    backups.sort((a, b) => (b['created'] as DateTime).compareTo(a['created'] as DateTime));
    return backups;
  }

  /// 删除备份文件
  Future<void> deleteBackup(String backupPath) async {
    final file = File(backupPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  /// 清理过期备份
  Future<void> cleanupExpiredBackups({int keepDays = 30}) async {
    final backupDir = await _getBackupDirectory();
    final expiredDate = DateTime.now().subtract(Duration(days: keepDays));

    if (await backupDir.exists()) {
      final files = backupDir.listSync()
          .where((entity) => entity is File && entity.path.endsWith('.zip'))
          .cast<File>()
          .toList();

      for (final file in files) {
        try {
          final stat = await file.stat();
          if (stat.modified.isBefore(expiredDate)) {
            await file.delete();
          }
        } catch (e) {
          // 忽略无法删除的文件
        }
      }
    }
  }

  // 私有方法

  /// 获取备份目录
  Future<Directory> _getBackupDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${appDir.path}/backups');
    
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    
    return backupDir;
  }

  /// 添加FAQ到归档
  Future<void> _addFaqsToArchive(Archive archive) async {
    // 模拟FAQ数据
    final faqsData = {
      'faqs': [
        {
          'id': '1',
          'question': '示例问题1',
          'answer': '示例答案1',
          'category': '常见问题',
          'tags': ['标签1', '标签2'],
          'priority': 1,
          'isActive': true,
        },
        {
          'id': '2',
          'question': '示例问题2',
          'answer': '示例答案2',
          'category': '技术支持',
          'tags': ['标签3'],
          'priority': 2,
          'isActive': true,
        },
      ],
    };

    final jsonContent = json.encode(faqsData);
    final file = ArchiveFile('faqs/faqs.json', jsonContent.length, jsonContent.codeUnits);
    archive.addFile(file);
  }

  /// 添加知识库到归档
  Future<void> _addKnowledgeBaseToArchive(Archive archive) async {
    // 模拟知识库数据
    final kbData = {
      'knowledge_bases': [
        {
          'id': '1',
          'name': '示例知识库',
          'description': '这是一个示例知识库',
          'created_at': DateTime.now().toIso8601String(),
        },
      ],
    };

    final jsonContent = json.encode(kbData);
    final file = ArchiveFile('knowledge_base/knowledge_bases.json', jsonContent.length, jsonContent.codeUnits);
    archive.addFile(file);
  }

  /// 添加文档到归档
  Future<void> _addDocumentsToArchive(Archive archive) async {
    // 模拟文档数据
    final docsData = {
      'documents': [
        {
          'id': '1',
          'title': '示例文档1',
          'content': '这是示例文档的内容',
          'category': '技术文档',
          'created_at': DateTime.now().toIso8601String(),
        },
      ],
    };

    final jsonContent = json.encode(docsData);
    final file = ArchiveFile('documents/documents.json', jsonContent.length, jsonContent.codeUnits);
    archive.addFile(file);
  }

  /// 添加对话到归档
  Future<void> _addConversationsToArchive(Archive archive) async {
    // 模拟对话数据
    final conversationsData = {
      'conversations': [
        {
          'id': '1',
          'title': '示例对话',
          'messages': [
            {
              'role': 'user',
              'content': '用户消息',
              'timestamp': DateTime.now().toIso8601String(),
            },
            {
              'role': 'assistant',
              'content': '助手回复',
              'timestamp': DateTime.now().toIso8601String(),
            },
          ],
          'created_at': DateTime.now().toIso8601String(),
        },
      ],
    };

    final jsonContent = json.encode(conversationsData);
    final file = ArchiveFile('conversations/conversations.json', jsonContent.length, jsonContent.codeUnits);
    archive.addFile(file);
  }

  /// 添加用户设置到归档
  Future<void> _addUserSettingsToArchive(Archive archive) async {
    // 模拟用户设置数据
    final settingsData = {
      'user_settings': {
        'theme': 'light',
        'language': 'zh-CN',
        'notifications': true,
        'auto_save': true,
      },
    };

    final jsonContent = json.encode(settingsData);
    final file = ArchiveFile('user_settings/settings.json', jsonContent.length, jsonContent.codeUnits);
    archive.addFile(file);
  }

  /// 添加备份元数据
  Future<void> _addBackupMetadata(Archive archive, String backupName, List<DataType>? dataTypes) async {
    final metadata = {
      'backup_name': backupName,
      'created_at': DateTime.now().toIso8601String(),
      'version': '1.0.0',
      'data_types': dataTypes?.map((e) => e.name).toList() ?? DataType.values.map((e) => e.name).toList(),
      'app_version': '1.0.0',
    };

    final jsonContent = json.encode(metadata);
    final file = ArchiveFile('backup_metadata.json', jsonContent.length, jsonContent.codeUnits);
    archive.addFile(file);
  }

  /// 读取备份元数据
  Future<Map<String, dynamic>> _readBackupMetadata(Archive archive) async {
    final metadataFile = archive.firstWhere((file) => file.name == 'backup_metadata.json');
    final content = String.fromCharCodes(metadataFile.content as List<int>);
    return json.decode(content) as Map<String, dynamic>;
  }

  /// 恢复FAQ数据
  Future<void> _restoreFaqs(String fileName, List<int> content) async {
    final jsonContent = String.fromCharCodes(content);
    final data = json.decode(jsonContent) as Map<String, dynamic>;
    // 在实际项目中，这里应该将数据保存到数据库
    print('恢复FAQ数据: ${data['faqs']?.length ?? 0} 条');
  }

  /// 恢复知识库数据
  Future<void> _restoreKnowledgeBase(String fileName, List<int> content) async {
    final jsonContent = String.fromCharCodes(content);
    final data = json.decode(jsonContent) as Map<String, dynamic>;
    // 在实际项目中，这里应该将数据保存到数据库
    print('恢复知识库数据: ${data['knowledge_bases']?.length ?? 0} 个');
  }

  /// 恢复文档数据
  Future<void> _restoreDocuments(String fileName, List<int> content) async {
    final jsonContent = String.fromCharCodes(content);
    final data = json.decode(jsonContent) as Map<String, dynamic>;
    // 在实际项目中，这里应该将数据保存到数据库
    print('恢复文档数据: ${data['documents']?.length ?? 0} 个');
  }

  /// 恢复对话数据
  Future<void> _restoreConversations(String fileName, List<int> content) async {
    final jsonContent = String.fromCharCodes(content);
    final data = json.decode(jsonContent) as Map<String, dynamic>;
    // 在实际项目中，这里应该将数据保存到数据库
    print('恢复对话数据: ${data['conversations']?.length ?? 0} 个');
  }

  /// 恢复用户设置数据
  Future<void> _restoreUserSettings(String fileName, List<int> content) async {
    final jsonContent = String.fromCharCodes(content);
    final data = json.decode(jsonContent) as Map<String, dynamic>;
    // 在实际项目中，这里应该将设置保存到SharedPreferences或数据库
    print('恢复用户设置: ${data['user_settings']}');
  }
} 