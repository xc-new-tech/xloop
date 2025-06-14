import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 工作流管理页面
/// 
/// 提供工作流程的设计、自动化配置、执行监控等功能
class WorkflowManagementPage extends StatefulWidget {
  const WorkflowManagementPage({super.key});

  @override
  State<WorkflowManagementPage> createState() => _WorkflowManagementPageState();
}

class _WorkflowManagementPageState extends State<WorkflowManagementPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  List<Workflow> _workflows = [];
  List<WorkflowExecution> _executions = [];
  bool _isCreatingWorkflow = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadWorkflowData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadWorkflowData() {
    // 模拟工作流数据
    _workflows = [
      Workflow(
        id: 'wf_1',
        name: '知识库审核流程',
        description: '新建知识库内容的审核和发布流程',
        status: WorkflowStatus.active,
        triggerType: TriggerType.manual,
        steps: [
          WorkflowStep(id: 'step_1', name: '内容检查', type: StepType.validation, order: 1),
          WorkflowStep(id: 'step_2', name: '专家审核', type: StepType.approval, order: 2),
          WorkflowStep(id: 'step_3', name: '发布内容', type: StepType.action, order: 3),
        ],
        created: DateTime.now().subtract(const Duration(days: 15)),
        lastModified: DateTime.now().subtract(const Duration(days: 2)),
        executionCount: 245,
        successRate: 94.2,
      ),
      Workflow(
        id: 'wf_2',
        name: '用户反馈处理',
        description: '自动分类和分发用户反馈到相关部门',
        status: WorkflowStatus.active,
        triggerType: TriggerType.automatic,
        steps: [
          WorkflowStep(id: 'step_1', name: '反馈分类', type: StepType.classification, order: 1),
          WorkflowStep(id: 'step_2', name: '分配处理人', type: StepType.assignment, order: 2),
          WorkflowStep(id: 'step_3', name: '发送通知', type: StepType.notification, order: 3),
        ],
        created: DateTime.now().subtract(const Duration(days: 8)),
        lastModified: DateTime.now().subtract(const Duration(hours: 6)),
        executionCount: 1420,
        successRate: 98.7,
      ),
      Workflow(
        id: 'wf_3',
        name: '定期报告生成',
        description: '每周自动生成系统使用情况报告',
        status: WorkflowStatus.paused,
        triggerType: TriggerType.scheduled,
        steps: [
          WorkflowStep(id: 'step_1', name: '数据收集', type: StepType.dataCollection, order: 1),
          WorkflowStep(id: 'step_2', name: '报告生成', type: StepType.generation, order: 2),
          WorkflowStep(id: 'step_3', name: '发送报告', type: StepType.delivery, order: 3),
        ],
        created: DateTime.now().subtract(const Duration(days: 30)),
        lastModified: DateTime.now().subtract(const Duration(days: 1)),
        executionCount: 12,
        successRate: 100.0,
      ),
    ];

    // 模拟执行记录
    _executions = [
      WorkflowExecution(
        id: 'exec_1',
        workflowId: 'wf_1',
        workflowName: '知识库审核流程',
        status: ExecutionStatus.completed,
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
        endTime: DateTime.now().subtract(const Duration(hours: 1)),
        triggerType: TriggerType.manual,
        currentStep: 3,
        totalSteps: 3,
      ),
      WorkflowExecution(
        id: 'exec_2',
        workflowId: 'wf_2',
        workflowName: '用户反馈处理',
        status: ExecutionStatus.running,
        startTime: DateTime.now().subtract(const Duration(minutes: 15)),
        triggerType: TriggerType.automatic,
        currentStep: 2,
        totalSteps: 3,
      ),
      WorkflowExecution(
        id: 'exec_3',
        workflowId: 'wf_1',
        workflowName: '知识库审核流程',
        status: ExecutionStatus.failed,
        startTime: DateTime.now().subtract(const Duration(hours: 4)),
        endTime: DateTime.now().subtract(const Duration(hours: 3, minutes: 45)),
        triggerType: TriggerType.manual,
        currentStep: 2,
        totalSteps: 3,
        errorMessage: '审核人员不可用',
      ),
    ];

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '工作流管理',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showCreateWorkflowDialog(),
            icon: const Icon(Icons.add),
            tooltip: '创建工作流',
          ),
          IconButton(
            onPressed: () => _refreshData(),
            icon: const Icon(Icons.refresh),
            tooltip: '刷新数据',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.list), text: '工作流列表'),
            Tab(icon: Icon(Icons.build), text: '流程设计'),
            Tab(icon: Icon(Icons.play_arrow), text: '执行监控'),
            Tab(icon: Icon(Icons.analytics), text: '分析报告'),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWorkflowListTab(),
          _buildWorkflowDesignTab(),
          _buildExecutionMonitorTab(),
          _buildAnalyticsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateWorkflowDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // 工作流列表标签页
  Widget _buildWorkflowListTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 统计卡片
        _buildWorkflowStats(),
        const SizedBox(height: 16),
        
        // 工作流列表
        ..._workflows.map((workflow) => _buildWorkflowCard(workflow)),
      ],
    );
  }

  Widget _buildWorkflowStats() {
    final activeCount = _workflows.where((w) => w.status == WorkflowStatus.active).length;
    final totalExecutions = _workflows.fold<int>(0, (sum, w) => sum + w.executionCount);
    final averageSuccessRate = _workflows.isEmpty ? 0.0 :
        _workflows.fold<double>(0, (sum, w) => sum + w.successRate) / _workflows.length;

    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '工作流概览',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '活跃工作流',
                    '$activeCount',
                    Icons.play_circle,
                    AppColors.success,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '总执行次数',
                    '$totalExecutions',
                    Icons.timeline,
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '平均成功率',
                    '${averageSuccessRate.toStringAsFixed(1)}%',
                    Icons.check_circle,
                    AppColors.tertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.titleMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWorkflowCard(Workflow workflow) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        color: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workflow.name,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          workflow.description,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildStatusChip(workflow.status),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildWorkflowInfo(
                    Icons.play_arrow,
                    _getTriggerTypeText(workflow.triggerType),
                  ),
                  const SizedBox(width: 16),
                  _buildWorkflowInfo(
                    Icons.layers,
                    '${workflow.steps.length} 步骤',
                  ),
                  const SizedBox(width: 16),
                  _buildWorkflowInfo(
                    Icons.timeline,
                    '${workflow.executionCount} 次执行',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    '成功率: ${workflow.successRate.toStringAsFixed(1)}%',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _editWorkflow(workflow),
                    child: const Text('编辑'),
                  ),
                  TextButton(
                    onPressed: () => _executeWorkflow(workflow),
                    child: const Text('执行'),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleWorkflowAction(value, workflow),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'duplicate', child: Text('复制')),
                      const PopupMenuItem(value: 'export', child: Text('导出')),
                      const PopupMenuItem(value: 'delete', child: Text('删除')),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(WorkflowStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case WorkflowStatus.active:
        color = AppColors.success;
        text = '活跃';
        break;
      case WorkflowStatus.paused:
        color = AppColors.warning;
        text = '暂停';
        break;
      case WorkflowStatus.inactive:
        color = AppColors.onSurfaceVariant;
        text = '未启用';
        break;
    }

    return Chip(
      label: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: color,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildWorkflowInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  // 流程设计标签页
  Widget _buildWorkflowDesignTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 模板选择
        _buildTemplateSelection(),
        const SizedBox(height: 16),
        
        // 设计画布
        _buildDesignCanvas(),
        const SizedBox(height: 16),
        
        // 步骤配置
        _buildStepConfiguration(),
      ],
    );
  }

  Widget _buildTemplateSelection() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '工作流模板',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _buildTemplateChip('审核流程', Icons.check_circle),
                _buildTemplateChip('数据处理', Icons.data_usage),
                _buildTemplateChip('通知发送', Icons.notifications),
                _buildTemplateChip('报告生成', Icons.assessment),
                _buildTemplateChip('自定义', Icons.build),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateChip(String name, IconData icon) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(name),
        ],
      ),
      selected: false,
      onSelected: (selected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择模板: $name')),
        );
      },
    );
  }

  Widget _buildDesignCanvas() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '流程设计',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.outline.withValues(alpha: 0.5),
                  style: BorderStyle.solid,
                ),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.gesture, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      '拖拽组件到此处设计工作流',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepConfiguration() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '步骤组件',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildStepComponent('开始', Icons.play_arrow, AppColors.success),
                _buildStepComponent('条件判断', Icons.alt_route, AppColors.warning),
                _buildStepComponent('用户任务', Icons.person, AppColors.primary),
                _buildStepComponent('自动任务', Icons.settings, AppColors.secondary),
                _buildStepComponent('发送通知', Icons.email, AppColors.tertiary),
                _buildStepComponent('结束', Icons.stop, AppColors.error),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepComponent(String name, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _addStepToCanvas(name, icon, color),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 执行监控标签页
  Widget _buildExecutionMonitorTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // 执行状态概览
        _buildExecutionOverview(),
        const SizedBox(height: 16),
        
        // 实时执行列表
        _buildExecutionList(),
      ],
    );
  }

  Widget _buildExecutionOverview() {
    final runningCount = _executions.where((e) => e.status == ExecutionStatus.running).length;
    final completedCount = _executions.where((e) => e.status == ExecutionStatus.completed).length;
    final failedCount = _executions.where((e) => e.status == ExecutionStatus.failed).length;

    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '执行状态概览',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildExecutionStatCard(
                    '运行中',
                    '$runningCount',
                    Icons.play_circle,
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildExecutionStatCard(
                    '已完成',
                    '$completedCount',
                    Icons.check_circle,
                    AppColors.success,
                  ),
                ),
                Expanded(
                  child: _buildExecutionStatCard(
                    '失败',
                    '$failedCount',
                    Icons.error_circle,
                    AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutionStatCard(String label, String count, IconData icon, Color color) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              count,
              style: AppTextStyles.headlineSmall.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutionList() {
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
                Text(
                  '执行记录',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _viewAllExecutions(),
                  child: const Text('查看全部'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._executions.map((execution) => _buildExecutionCard(execution)),
          ],
        ),
      ),
    );
  }

  Widget _buildExecutionCard(WorkflowExecution execution) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildExecutionStatusIcon(execution.status),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  execution.workflowName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '步骤 ${execution.currentStep}/${execution.totalSteps}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                if (execution.errorMessage != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    execution.errorMessage!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatExecutionTime(execution),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              if (execution.status == ExecutionStatus.running)
                SizedBox(
                  width: 60,
                  child: LinearProgressIndicator(
                    value: execution.currentStep / execution.totalSteps,
                    backgroundColor: AppColors.surfaceVariant,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExecutionStatusIcon(ExecutionStatus status) {
    IconData icon;
    Color color;
    
    switch (status) {
      case ExecutionStatus.running:
        icon = Icons.play_circle;
        color = AppColors.primary;
        break;
      case ExecutionStatus.completed:
        icon = Icons.check_circle;
        color = AppColors.success;
        break;
      case ExecutionStatus.failed:
        icon = Icons.error_circle;
        color = AppColors.error;
        break;
      case ExecutionStatus.paused:
        icon = Icons.pause_circle;
        color = AppColors.warning;
        break;
    }

    return Icon(icon, color: color, size: 24);
  }

  // 分析报告标签页
  Widget _buildAnalyticsTab() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildPerformanceMetrics(),
        const SizedBox(height: 16),
        _buildUsageAnalytics(),
        const SizedBox(height: 16),
        _buildTrendAnalysis(),
      ],
    );
  }

  Widget _buildPerformanceMetrics() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '性能指标',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    '平均执行时间',
                    '2.3分钟',
                    Icons.timer,
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildMetricCard(
                    '成功率',
                    '96.4%',
                    Icons.check_circle,
                    AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(
                    '错误率',
                    '3.6%',
                    Icons.error,
                    AppColors.error,
                  ),
                ),
                Expanded(
                  child: _buildMetricCard(
                    '并发数',
                    '15',
                    Icons.timeline,
                    AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.titleMedium.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageAnalytics() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '使用情况分析',
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
                child: Text('使用情况图表 (需要图表库实现)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendAnalysis() {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '趋势分析',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildTrendItem('本周执行次数', '+15%', true),
            _buildTrendItem('平均执行时间', '-8%', false),
            _buildTrendItem('成功率', '+2.1%', true),
            _buildTrendItem('用户参与度', '+23%', true),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendItem(String label, String change, bool isPositive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: isPositive ? AppColors.success : AppColors.error,
            size: 20,
          ),
          const SizedBox(width: 4),
          Text(
            change,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isPositive ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // 辅助方法
  String _getTriggerTypeText(TriggerType type) {
    switch (type) {
      case TriggerType.manual:
        return '手动触发';
      case TriggerType.automatic:
        return '自动触发';
      case TriggerType.scheduled:
        return '定时触发';
    }
  }

  String _formatExecutionTime(WorkflowExecution execution) {
    final now = DateTime.now();
    final difference = now.difference(execution.startTime);
    
    if (difference.inMinutes < 1) {
      return '刚刚开始';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}小时前';
    } else {
      return '${difference.inDays}天前';
    }
  }

  // 事件处理方法
  void _refreshData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在刷新工作流数据...')),
    );
    _loadWorkflowData();
  }

  void _showCreateWorkflowDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建工作流'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: '工作流名称',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: '描述',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _tabController.animateTo(1); // 切换到设计标签页
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('开始设计新工作流')),
              );
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _editWorkflow(Workflow workflow) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('编辑工作流: ${workflow.name}')),
    );
  }

  void _executeWorkflow(Workflow workflow) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('执行工作流: ${workflow.name}')),
    );
  }

  void _handleWorkflowAction(String action, Workflow workflow) {
    switch (action) {
      case 'duplicate':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('复制工作流: ${workflow.name}')),
        );
        break;
      case 'export':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出工作流: ${workflow.name}')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(workflow);
        break;
    }
  }

  void _showDeleteConfirmation(Workflow workflow) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除工作流 "${workflow.name}" 吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _workflows.remove(workflow);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已删除工作流: ${workflow.name}')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.onError,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _addStepToCanvas(String name, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('添加步骤到画布: $name')),
    );
  }

  void _viewAllExecutions() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('查看所有执行记录')),
    );
  }
}

// 数据模型

enum WorkflowStatus { active, paused, inactive }
enum TriggerType { manual, automatic, scheduled }
enum StepType { validation, approval, action, classification, assignment, notification, dataCollection, generation, delivery }
enum ExecutionStatus { running, completed, failed, paused }

class Workflow {
  final String id;
  final String name;
  final String description;
  final WorkflowStatus status;
  final TriggerType triggerType;
  final List<WorkflowStep> steps;
  final DateTime created;
  final DateTime lastModified;
  final int executionCount;
  final double successRate;

  Workflow({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.triggerType,
    required this.steps,
    required this.created,
    required this.lastModified,
    required this.executionCount,
    required this.successRate,
  });
}

class WorkflowStep {
  final String id;
  final String name;
  final StepType type;
  final int order;

  WorkflowStep({
    required this.id,
    required this.name,
    required this.type,
    required this.order,
  });
}

class WorkflowExecution {
  final String id;
  final String workflowId;
  final String workflowName;
  final ExecutionStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final TriggerType triggerType;
  final int currentStep;
  final int totalSteps;
  final String? errorMessage;

  WorkflowExecution({
    required this.id,
    required this.workflowId,
    required this.workflowName,
    required this.status,
    required this.startTime,
    this.endTime,
    required this.triggerType,
    required this.currentStep,
    required this.totalSteps,
    this.errorMessage,
  });
} 