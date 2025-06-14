import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// API文档管理页面
/// 
/// 提供API端点管理、文档生成、测试工具、监控等功能
class ApiManagementPage extends StatefulWidget {
  const ApiManagementPage({super.key});

  @override
  State<ApiManagementPage> createState() => _ApiManagementPageState();
}

class _ApiManagementPageState extends State<ApiManagementPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  List<ApiEndpoint> _endpoints = [];
  List<ApiDocumentation> _documents = [];
  List<ApiTestCase> _testCases = [];
  ApiMonitoringData? _monitoringData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMockData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    // 模拟API端点数据
    _endpoints = [
      ApiEndpoint(
        id: 'auth_login',
        name: '用户登录',
        method: HttpMethod.post,
        path: '/api/auth/login',
        description: '用户身份验证登录接口',
        status: ApiStatus.active,
        version: 'v1',
        lastModified: DateTime.now().subtract(const Duration(hours: 2)),
        requestBody: {'email': 'string', 'password': 'string'},
        responseBody: {'token': 'string', 'user': 'object'},
        tags: ['认证', '登录'],
      ),
      ApiEndpoint(
        id: 'knowledge_list',
        name: '获取知识库列表',
        method: HttpMethod.get,
        path: '/api/knowledge-bases',
        description: '获取用户可访问的知识库列表',
        status: ApiStatus.active,
        version: 'v1',
        lastModified: DateTime.now().subtract(const Duration(days: 1)),
        requestBody: null,
        responseBody: {'data': 'array', 'total': 'number'},
        tags: ['知识库', '列表'],
      ),
      ApiEndpoint(
        id: 'search_semantic',
        name: '语义搜索',
        method: HttpMethod.post,
        path: '/api/search/semantic',
        description: '基于自然语言的智能搜索接口',
        status: ApiStatus.beta,
        version: 'v2',
        lastModified: DateTime.now().subtract(const Duration(hours: 6)),
        requestBody: {'query': 'string', 'limit': 'number'},
        responseBody: {'results': 'array', 'total': 'number', 'duration': 'number'},
        tags: ['搜索', 'AI', '语义'],
      ),
      ApiEndpoint(
        id: 'file_upload',
        name: '文件上传',
        method: HttpMethod.post,
        path: '/api/files/upload',
        description: '支持多种格式的文件上传接口',
        status: ApiStatus.deprecated,
        version: 'v1',
        lastModified: DateTime.now().subtract(const Duration(days: 7)),
        requestBody: {'file': 'multipart/form-data'},
        responseBody: {'fileId': 'string', 'url': 'string'},
        tags: ['文件', '上传'],
      ),
    ];

    // 模拟API文档数据
    _documents = [
      ApiDocumentation(
        id: 'auth_docs',
        title: '用户认证API文档',
        version: 'v1.2.0',
        lastGenerated: DateTime.now().subtract(const Duration(hours: 3)),
        endpoints: ['auth_login', 'auth_logout', 'auth_refresh'],
        format: DocumentFormat.openApi,
        downloadUrl: '/docs/auth-api-v1.2.0.json',
      ),
      ApiDocumentation(
        id: 'knowledge_docs',
        title: '知识库管理API文档',
        version: 'v2.1.0',
        lastGenerated: DateTime.now().subtract(const Duration(days: 2)),
        endpoints: ['knowledge_list', 'knowledge_create', 'knowledge_update'],
        format: DocumentFormat.markdown,
        downloadUrl: '/docs/knowledge-api-v2.1.0.md',
      ),
    ];

    // 模拟测试用例数据
    _testCases = [
      ApiTestCase(
        id: 'test_login_success',
        name: '登录成功测试',
        endpointId: 'auth_login',
        method: HttpMethod.post,
        testData: {'email': 'test@example.com', 'password': 'password123'},
        expectedStatus: 200,
        lastRun: DateTime.now().subtract(const Duration(minutes: 30)),
        status: TestStatus.passed,
      ),
      ApiTestCase(
        id: 'test_login_invalid',
        name: '登录失败测试',
        endpointId: 'auth_login',
        method: HttpMethod.post,
        testData: {'email': 'invalid@example.com', 'password': 'wrongpass'},
        expectedStatus: 401,
        lastRun: DateTime.now().subtract(const Duration(hours: 1)),
        status: TestStatus.failed,
      ),
    ];

    // 模拟监控数据
    _monitoringData = ApiMonitoringData(
      totalRequests: 45623,
      successRate: 0.986,
      averageResponseTime: 245,
      activeEndpoints: 12,
      dailyRequests: [120, 156, 189, 203, 167, 145, 198],
      responseTimeHistory: [230, 245, 251, 238, 267, 252, 241],
      topEndpoints: [
        EndpointUsage(endpoint: '/api/search/semantic', requests: 8945),
        EndpointUsage(endpoint: '/api/knowledge-bases', requests: 6234),
        EndpointUsage(endpoint: '/api/auth/login', requests: 4567),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'API文档管理',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showApiImportDialog(),
            icon: const Icon(Icons.upload_file),
            tooltip: '导入API',
          ),
          IconButton(
            onPressed: () => _generateAllDocumentation(),
            icon: const Icon(Icons.auto_awesome),
            tooltip: '生成文档',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.api), text: 'API端点'),
            Tab(icon: Icon(Icons.description), text: '文档管理'),
            Tab(icon: Icon(Icons.bug_report), text: '测试工具'),
            Tab(icon: Icon(Icons.analytics), text: 'API监控'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEndpointsTab(),
          _buildDocumentationTab(),
          _buildTestingTab(),
          _buildMonitoringTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    final currentIndex = _tabController.index;
    switch (currentIndex) {
      case 0: // API端点
        return FloatingActionButton(
          onPressed: () => _showAddEndpointDialog(),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add),
        );
      case 1: // 文档管理
        return FloatingActionButton(
          onPressed: () => _showGenerateDocumentationDialog(),
          backgroundColor: AppColors.secondary,
          child: const Icon(Icons.auto_stories),
        );
      case 2: // 测试工具
        return FloatingActionButton(
          onPressed: () => _showAddTestCaseDialog(),
          backgroundColor: AppColors.tertiary,
          child: const Icon(Icons.science),
        );
      default:
        return FloatingActionButton(
          onPressed: () => _refreshMonitoring(),
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.refresh),
        );
    }
  }

  // API端点管理标签页
  Widget _buildEndpointsTab() {
    return Column(
      children: [
        // 搜索和筛选栏
        Container(
          padding: const EdgeInsets.all(16.0),
          color: AppColors.surface,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '搜索API端点...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _showFilterDialog(),
                icon: const Icon(Icons.filter_list),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceVariant,
                ),
              ),
            ],
          ),
        ),
        // API端点列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _endpoints.length,
            itemBuilder: (context, index) {
              final endpoint = _endpoints[index];
              return _buildEndpointCard(endpoint);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEndpointCard(ApiEndpoint endpoint) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.outline.withValues(alpha: 0.2)),
      ),
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getMethodColor(endpoint.method).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            endpoint.method.name.toUpperCase(),
            style: AppTextStyles.bodySmall.copyWith(
              color: _getMethodColor(endpoint.method),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          endpoint.name,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              endpoint.path,
              style: AppTextStyles.bodyMedium.copyWith(
                fontFamily: 'monospace',
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor(endpoint.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusText(endpoint.status),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _getStatusColor(endpoint.status),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  endpoint.version,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleEndpointAction(value, endpoint),
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'edit', child: Text('编辑')),
            const PopupMenuItem(value: 'test', child: Text('测试')),
            const PopupMenuItem(value: 'docs', child: Text('生成文档')),
            const PopupMenuItem(value: 'delete', child: Text('删除')),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  endpoint.description,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 12),
                
                // 标签
                if (endpoint.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: endpoint.tags.map((tag) => Chip(
                      label: Text(tag),
                      labelStyle: AppTextStyles.bodySmall,
                      backgroundColor: AppColors.primaryContainer,
                      side: BorderSide.none,
                    )).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // 请求/响应示例
                if (endpoint.requestBody != null) ...[
                  Text(
                    '请求体示例:',
                    style: AppTextStyles.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatJson(endpoint.requestBody!),
                      style: AppTextStyles.bodySmall.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                
                Text(
                  '响应体示例:',
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatJson(endpoint.responseBody),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 文档管理标签页
  Widget _buildDocumentationTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 文档生成选项
        Card(
          elevation: 0,
          color: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '文档生成',
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildDocFormatButton('OpenAPI 3.0', DocumentFormat.openApi),
                    _buildDocFormatButton('Markdown', DocumentFormat.markdown),
                    _buildDocFormatButton('HTML', DocumentFormat.html),
                    _buildDocFormatButton('PDF', DocumentFormat.pdf),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // 现有文档列表
        ..._documents.map((doc) => _buildDocumentationCard(doc)),
      ],
    );
  }

  Widget _buildDocFormatButton(String label, DocumentFormat format) {
    return ElevatedButton.icon(
      onPressed: () => _generateDocumentation(format),
      icon: Icon(_getDocumentFormatIcon(format)),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: AppColors.onPrimaryContainer,
      ),
    );
  }

  Widget _buildDocumentationCard(ApiDocumentation doc) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: AppColors.surface,
      child: ListTile(
        leading: Icon(
          _getDocumentFormatIcon(doc.format),
          color: AppColors.primary,
        ),
        title: Text(
          doc.title,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('版本: ${doc.version}'),
            Text('生成时间: ${_formatDateTime(doc.lastGenerated)}'),
            Text('包含 ${doc.endpoints.length} 个端点'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _previewDocumentation(doc),
              icon: const Icon(Icons.preview),
              tooltip: '预览',
            ),
            IconButton(
              onPressed: () => _downloadDocumentation(doc),
              icon: const Icon(Icons.download),
              tooltip: '下载',
            ),
          ],
        ),
      ),
    );
  }

  // 测试工具标签页
  Widget _buildTestingTab() {
    return Column(
      children: [
        // 测试控制栏
        Container(
          padding: const EdgeInsets.all(16.0),
          color: AppColors.surface,
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () => _runAllTests(),
                icon: const Icon(Icons.play_arrow),
                label: const Text('运行所有测试'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => _importTestCases(),
                icon: const Icon(Icons.upload_file),
                label: const Text('导入测试'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: AppColors.onSecondary,
                ),
              ),
              const Spacer(),
              _buildTestStatusSummary(),
            ],
          ),
        ),
        
        // 测试用例列表
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _testCases.length,
            itemBuilder: (context, index) {
              final testCase = _testCases[index];
              return _buildTestCaseCard(testCase);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTestStatusSummary() {
    final passedCount = _testCases.where((t) => t.status == TestStatus.passed).length;
    final failedCount = _testCases.where((t) => t.status == TestStatus.failed).length;
    final totalCount = _testCases.length;
    
    return Row(
      children: [
        Icon(Icons.check_circle, color: AppColors.success, size: 16),
        const SizedBox(width: 4),
        Text('$passedCount', style: AppTextStyles.bodySmall),
        const SizedBox(width: 12),
        Icon(Icons.error, color: AppColors.error, size: 16),
        const SizedBox(width: 4),
        Text('$failedCount', style: AppTextStyles.bodySmall),
        const SizedBox(width: 12),
        Text('总计: $totalCount', style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildTestCaseCard(ApiTestCase testCase) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: AppColors.surface,
      child: ListTile(
        leading: Icon(
          _getTestStatusIcon(testCase.status),
          color: _getTestStatusColor(testCase.status),
        ),
        title: Text(
          testCase.name,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('端点: ${testCase.endpointId}'),
            Text('最后运行: ${_formatDateTime(testCase.lastRun)}'),
            Text('期望状态码: ${testCase.expectedStatus}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => _runTestCase(testCase),
              icon: const Icon(Icons.play_arrow),
              tooltip: '运行测试',
            ),
            IconButton(
              onPressed: () => _editTestCase(testCase),
              icon: const Icon(Icons.edit),
              tooltip: '编辑',
            ),
          ],
        ),
      ),
    );
  }

  // API监控标签页
  Widget _buildMonitoringTab() {
    if (_monitoringData == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 关键指标卡片
        Row(
          children: [
            Expanded(child: _buildMetricCard(
              '总请求数',
              _monitoringData!.totalRequests.toString(),
              Icons.analytics,
              AppColors.primary,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard(
              '成功率',
              '${(_monitoringData!.successRate * 100).toStringAsFixed(1)}%',
              Icons.check_circle,
              AppColors.success,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildMetricCard(
              '平均响应时间',
              '${_monitoringData!.averageResponseTime}ms',
              Icons.speed,
              AppColors.warning,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildMetricCard(
              '活跃端点',
              _monitoringData!.activeEndpoints.toString(),
              Icons.api,
              AppColors.secondary,
            )),
          ],
        ),
        const SizedBox(height: 24),
        
        // 请求趋势图
        _buildTrendChart(),
        const SizedBox(height: 24),
        
        // 热门端点排行
        _buildTopEndpointsList(),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.headlineSmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '每日请求趋势',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('趋势图表 (需要图表库实现)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopEndpointsList() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '热门API端点',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...(_monitoringData!.topEndpoints.asMap().entries.map((entry) {
              final index = entry.key;
              final endpoint = entry.value;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    '${index + 1}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  endpoint.endpoint,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontFamily: 'monospace',
                  ),
                ),
                trailing: Text(
                  '${endpoint.requests} 次',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            })),
          ],
        ),
      ),
    );
  }

  // 辅助方法
  Color _getMethodColor(HttpMethod method) {
    switch (method) {
      case HttpMethod.get:
        return AppColors.success;
      case HttpMethod.post:
        return AppColors.primary;
      case HttpMethod.put:
        return AppColors.warning;
      case HttpMethod.delete:
        return AppColors.error;
      case HttpMethod.patch:
        return AppColors.secondary;
    }
  }

  Color _getStatusColor(ApiStatus status) {
    switch (status) {
      case ApiStatus.active:
        return AppColors.success;
      case ApiStatus.beta:
        return AppColors.warning;
      case ApiStatus.deprecated:
        return AppColors.error;
      case ApiStatus.inactive:
        return AppColors.onSurfaceVariant;
    }
  }

  String _getStatusText(ApiStatus status) {
    switch (status) {
      case ApiStatus.active:
        return '活跃';
      case ApiStatus.beta:
        return '测试';
      case ApiStatus.deprecated:
        return '已弃用';
      case ApiStatus.inactive:
        return '不活跃';
    }
  }

  IconData _getDocumentFormatIcon(DocumentFormat format) {
    switch (format) {
      case DocumentFormat.openApi:
        return Icons.api;
      case DocumentFormat.markdown:
        return Icons.description;
      case DocumentFormat.html:
        return Icons.web;
      case DocumentFormat.pdf:
        return Icons.picture_as_pdf;
    }
  }

  IconData _getTestStatusIcon(TestStatus status) {
    switch (status) {
      case TestStatus.passed:
        return Icons.check_circle;
      case TestStatus.failed:
        return Icons.error;
      case TestStatus.pending:
        return Icons.pending;
    }
  }

  Color _getTestStatusColor(TestStatus status) {
    switch (status) {
      case TestStatus.passed:
        return AppColors.success;
      case TestStatus.failed:
        return AppColors.error;
      case TestStatus.pending:
        return AppColors.warning;
    }
  }

  String _formatJson(Map<String, dynamic> json) {
    return json.entries.map((e) => '  "${e.key}": "${e.value}"').join(',\n');
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}月${dateTime.day}日 ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  // 事件处理方法
  void _handleEndpointAction(String action, ApiEndpoint endpoint) {
    switch (action) {
      case 'edit':
        _editEndpoint(endpoint);
        break;
      case 'test':
        _testEndpoint(endpoint);
        break;
      case 'docs':
        _generateEndpointDocumentation(endpoint);
        break;
      case 'delete':
        _deleteEndpoint(endpoint);
        break;
    }
  }

  void _showApiImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导入API定义'),
        content: const Text('支持OpenAPI、Postman Collection等格式...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('导入'),
          ),
        ],
      ),
    );
  }

  void _generateAllDocumentation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在生成全部API文档...')),
    );
  }

  void _showAddEndpointDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加API端点'),
        content: const Text('API端点创建表单...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选API端点'),
        content: const Text('筛选选项...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showGenerateDocumentationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('生成文档'),
        content: const Text('文档生成配置...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('生成'),
          ),
        ],
      ),
    );
  }

  void _showAddTestCaseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加测试用例'),
        content: const Text('测试用例配置...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }

  void _refreshMonitoring() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在刷新监控数据...')),
    );
  }

  void _editEndpoint(ApiEndpoint endpoint) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('编辑端点: ${endpoint.name}')),
    );
  }

  void _testEndpoint(ApiEndpoint endpoint) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('测试端点: ${endpoint.path}')),
    );
  }

  void _generateEndpointDocumentation(ApiEndpoint endpoint) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('为 ${endpoint.name} 生成文档')),
    );
  }

  void _deleteEndpoint(ApiEndpoint endpoint) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除确认'),
        content: Text('确定要删除端点 "${endpoint.name}" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _endpoints.remove(endpoint);
              });
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _generateDocumentation(DocumentFormat format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('生成 ${format.name} 格式文档...')),
    );
  }

  void _previewDocumentation(ApiDocumentation doc) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('预览文档: ${doc.title}')),
    );
  }

  void _downloadDocumentation(ApiDocumentation doc) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('下载文档: ${doc.title}')),
    );
  }

  void _runAllTests() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('运行所有测试用例...')),
    );
  }

  void _importTestCases() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('导入测试用例...')),
    );
  }

  void _runTestCase(ApiTestCase testCase) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('运行测试: ${testCase.name}')),
    );
  }

  void _editTestCase(ApiTestCase testCase) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('编辑测试: ${testCase.name}')),
    );
  }
}

// 数据模型

enum HttpMethod { get, post, put, delete, patch }

enum ApiStatus { active, beta, deprecated, inactive }

enum DocumentFormat { openApi, markdown, html, pdf }

enum TestStatus { passed, failed, pending }

class ApiEndpoint {
  final String id;
  final String name;
  final HttpMethod method;
  final String path;
  final String description;
  final ApiStatus status;
  final String version;
  final DateTime lastModified;
  final Map<String, dynamic>? requestBody;
  final Map<String, dynamic> responseBody;
  final List<String> tags;

  ApiEndpoint({
    required this.id,
    required this.name,
    required this.method,
    required this.path,
    required this.description,
    required this.status,
    required this.version,
    required this.lastModified,
    this.requestBody,
    required this.responseBody,
    required this.tags,
  });
}

class ApiDocumentation {
  final String id;
  final String title;
  final String version;
  final DateTime lastGenerated;
  final List<String> endpoints;
  final DocumentFormat format;
  final String downloadUrl;

  ApiDocumentation({
    required this.id,
    required this.title,
    required this.version,
    required this.lastGenerated,
    required this.endpoints,
    required this.format,
    required this.downloadUrl,
  });
}

class ApiTestCase {
  final String id;
  final String name;
  final String endpointId;
  final HttpMethod method;
  final Map<String, dynamic> testData;
  final int expectedStatus;
  final DateTime lastRun;
  final TestStatus status;

  ApiTestCase({
    required this.id,
    required this.name,
    required this.endpointId,
    required this.method,
    required this.testData,
    required this.expectedStatus,
    required this.lastRun,
    required this.status,
  });
}

class ApiMonitoringData {
  final int totalRequests;
  final double successRate;
  final int averageResponseTime;
  final int activeEndpoints;
  final List<int> dailyRequests;
  final List<int> responseTimeHistory;
  final List<EndpointUsage> topEndpoints;

  ApiMonitoringData({
    required this.totalRequests,
    required this.successRate,
    required this.averageResponseTime,
    required this.activeEndpoints,
    required this.dailyRequests,
    required this.responseTimeHistory,
    required this.topEndpoints,
  });
}

class EndpointUsage {
  final String endpoint;
  final int requests;

  EndpointUsage({
    required this.endpoint,
    required this.requests,
  });
} 