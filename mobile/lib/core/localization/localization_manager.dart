/// 本地化管理器
class LocalizationManager {
  // 静态实例
  static LocalizationManager? _instance;
  
  // 私有构造函数
  LocalizationManager._();
  
  // 获取实例
  factory LocalizationManager() {
    return _instance ??= LocalizationManager._();
  }
  
  // 当前语言代码
  String _currentLanguage = 'zh';
  
  // 语言映射
  final Map<String, Map<String, String>> _translations = {
    'zh': {
      // 通用
      'common.unknown_error': '未知错误',
      'common.network_error': '网络错误',
      'common.server_error': '服务器错误',
      'common.auth_error': '认证错误',
      'common.validation_error': '验证错误',
      'common.loading': '加载中...',
      'common.retry': '重试',
      'common.cancel': '取消',
      'common.confirm': '确认',
      'common.success': '成功',
      'common.error': '错误',
      
      // 知识库
      'knowledge_base.empty': '暂无知识库',
      'knowledge_base.my_empty': '您还没有创建知识库',
      'knowledge_base.public_empty': '暂无公开知识库',
      'knowledge_base.search_empty': '搜索结果为空',
      'knowledge_base.create_success': '知识库创建成功',
      'knowledge_base.update_success': '知识库更新成功',
      'knowledge_base.delete_success': '知识库删除成功',
      'knowledge_base.status_update_success': '状态更新成功',
      'knowledge_base.duplicate_success': '知识库复制成功',
      'knowledge_base.share_success': '知识库分享成功',
      'knowledge_base.import_success': '知识库导入成功',
      'knowledge_base.export_success': '知识库导出成功',
      'knowledge_base.batch_delete_success': '批量删除成功',
      'knowledge_base.batch_status_update_success': '批量状态更新成功',
    },
    'en': {
      // Common
      'common.unknown_error': 'Unknown error',
      'common.network_error': 'Network error',
      'common.server_error': 'Server error',
      'common.auth_error': 'Authentication error',
      'common.validation_error': 'Validation error',
      'common.loading': 'Loading...',
      'common.retry': 'Retry',
      'common.cancel': 'Cancel',
      'common.confirm': 'Confirm',
      'common.success': 'Success',
      'common.error': 'Error',
      
      // Knowledge Base
      'knowledge_base.empty': 'No knowledge bases',
      'knowledge_base.my_empty': 'You haven\'t created any knowledge bases yet',
      'knowledge_base.public_empty': 'No public knowledge bases',
      'knowledge_base.search_empty': 'No search results',
      'knowledge_base.create_success': 'Knowledge base created successfully',
      'knowledge_base.update_success': 'Knowledge base updated successfully',
      'knowledge_base.delete_success': 'Knowledge base deleted successfully',
      'knowledge_base.status_update_success': 'Status updated successfully',
      'knowledge_base.duplicate_success': 'Knowledge base duplicated successfully',
      'knowledge_base.share_success': 'Knowledge base shared successfully',
      'knowledge_base.import_success': 'Knowledge base imported successfully',
      'knowledge_base.export_success': 'Knowledge base exported successfully',
      'knowledge_base.batch_delete_success': 'Batch deletion successful',
      'knowledge_base.batch_status_update_success': 'Batch status update successful',
    },
  };
  
  /// 获取当前语言
  String get currentLanguage => _currentLanguage;
  
  /// 设置语言
  void setLanguage(String languageCode) {
    if (_translations.containsKey(languageCode)) {
      _currentLanguage = languageCode;
    }
  }
  
  /// 获取翻译文本
  String getString(String key, {List<String>? args}) {
    final currentTranslations = _translations[_currentLanguage] ?? _translations['zh']!;
    String text = currentTranslations[key] ?? key;
    
    // 如果有参数，进行替换
    if (args != null && args.isNotEmpty) {
      for (int i = 0; i < args.length; i++) {
        text = text.replaceAll('{$i}', args[i]);
      }
    }
    
    return text;
  }
  
  /// 获取支持的语言列表
  List<String> getSupportedLanguages() {
    return _translations.keys.toList();
  }
} 