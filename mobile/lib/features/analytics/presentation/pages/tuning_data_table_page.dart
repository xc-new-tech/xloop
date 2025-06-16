import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';

/// 调优数据表格页面
class TuningDataTablePage extends StatefulWidget {
  const TuningDataTablePage({super.key});

  @override
  State<TuningDataTablePage> createState() => _TuningDataTablePageState();
}

class _TuningDataTablePageState extends State<TuningDataTablePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  
  // 数据模式切换
  DataMode _currentMode = DataMode.client;
  
  // 筛选条件
  DateFilterType _dateFilter = DateFilterType.today;
  String _deviceFilter = '';
  QualityFilter _qualityFilter = QualityFilter.all;
  DateTime? _customStartDate;
  DateTime? _customEndDate;
  String _searchQuery = '';
  
  // 表格数据
  List<TuningDataItem> _data = [];
  List<TuningDataItem> _filteredData = [];
  
  // 分页
  int _currentPage = 1;
  int _itemsPerPage = 20;
  int _totalItems = 0;
  
  // 选择状态
  Set<String> _selectedItems = {};
  bool _isSelectAll = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    // TODO: 实际数据加载逻辑
    _data = _generateMockData();
    _applyFilters();
  }

  List<TuningDataItem> _generateMockData() {
    final List<TuningDataItem> mockData = [];
    final random = DateTime.now().millisecondsSinceEpoch;
    
    for (int i = 0; i < 100; i++) {
      mockData.add(TuningDataItem(
        id: 'session_${i + 1}',
        deviceId: 'device_${(i % 10) + 1}',
        sessionId: 'sess_${random + i}',
        sessionDate: DateTime.now().subtract(Duration(days: i % 30)),
        question: _getRandomQuestion(i),
        retrievedAnswer: _getRandomAnswer(i),
        dataQuality: i % 3 == 0 ? DataQuality.needsAdjustment : DataQuality.good,
        tags: _getRandomTags(i),
        mode: i % 2 == 0 ? DataMode.client : DataMode.workspace,
      ));
    }
    
    return mockData;
  }

  String _getRandomQuestion(int index) {
    final questions = [
      '如何配置知识库权限？',
      '怎样提高搜索准确性？',
      '如何导入大量文档？',
      '系统响应速度慢怎么办？',
      '如何设置用户角色？',
      '知识库备份如何操作？',
      '如何优化AI回答质量？',
      '多语言支持如何配置？',
      '如何监控系统性能？',
      '数据安全如何保障？',
    ];
    return questions[index % questions.length];
  }

  String _getRandomAnswer(int index) {
    final answers = [
      '您可以在知识库设置中配置权限，支持公开、团队、私有三种模式...',
      '建议优化关键词设置，使用同义词扩展，调整搜索算法参数...',
      '支持批量导入，建议使用标准格式，分批次上传避免超时...',
      '请检查网络连接，清理缓存，或联系技术支持进行性能优化...',
      '在用户管理中可以设置管理员、编辑者、查看者等不同角色...',
    ];
    return answers[index % answers.length];
  }

  List<String> _getRandomTags(int index) {
    final allTags = ['权限', '搜索', '导入', '性能', '用户管理', '备份', 'AI优化', '多语言', '监控', '安全'];
    final tagCount = (index % 3) + 1;
    return allTags.take(tagCount).toList();
  }

  void _applyFilters() {
    _filteredData = _data.where((item) {
      // 数据模式筛选
      if (item.mode != _currentMode) return false;
      
      // 日期筛选
      if (!_matchesDateFilter(item.sessionDate)) return false;
      
      // 设备筛选
      if (_deviceFilter.isNotEmpty && !item.deviceId.contains(_deviceFilter)) return false;
      
      // 质量筛选
      if (_qualityFilter != QualityFilter.all && 
          !_matchesQualityFilter(item.dataQuality)) return false;
      
      // 搜索筛选
      if (_searchQuery.isNotEmpty && 
          !item.question.toLowerCase().contains(_searchQuery.toLowerCase()) &&
          !item.retrievedAnswer.toLowerCase().contains(_searchQuery.toLowerCase())) return false;
      
      return true;
    }).toList();
    
    _totalItems = _filteredData.length;
    setState(() {});
  }

  bool _matchesDateFilter(DateTime date) {
    final now = DateTime.now();
    switch (_dateFilter) {
      case DateFilterType.today:
        return date.year == now.year && date.month == now.month && date.day == now.day;
      case DateFilterType.lastWeek:
        return now.difference(date).inDays <= 7;
      case DateFilterType.lastMonth:
        return now.difference(date).inDays <= 30;
      case DateFilterType.custom:
        if (_customStartDate != null && _customEndDate != null) {
          return date.isAfter(_customStartDate!) && date.isBefore(_customEndDate!);
        }
        return true;
    }
  }

  bool _matchesQualityFilter(DataQuality quality) {
    switch (_qualityFilter) {
      case QualityFilter.all:
        return true;
      case QualityFilter.good:
        return quality == DataQuality.good;
      case QualityFilter.needsAdjustment:
        return quality == DataQuality.needsAdjustment;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '调优数据分析',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _exportData,
            icon: const Icon(Icons.download),
            tooltip: '导出数据',
          ),
          IconButton(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            tooltip: '刷新数据',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            setState(() {
              _currentMode = index == 0 ? DataMode.client : DataMode.workspace;
              _applyFilters();
            });
          },
          tabs: const [
            Tab(
              icon: Icon(Icons.phone_android),
              text: '客户端数据',
            ),
            Tab(
              icon: Icon(Icons.work),
              text: '工作端数据',
            ),
          ],
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          indicatorColor: AppColors.primary,
        ),
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          _buildDataTable(),
          _buildPaginationSection(),
        ],
      ),
      floatingActionButton: _selectedItems.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _showBatchActions,
              icon: const Icon(Icons.auto_fix_high),
              label: Text('批量调优 (${_selectedItems.length})'),
              backgroundColor: AppColors.primary,
            )
          : null,
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // 搜索栏
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  name: 'search',
                  hintText: '搜索问题或答案...',
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (value) {
                    _searchQuery = value ?? '';
                    _applyFilters();
                  },
                ),
              ),
              SizedBox(width: 12.w),
              CustomButton(
                text: '高级筛选',
                onPressed: _showAdvancedFilters,
                isOutlined: true,
                width: 100,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // 快速筛选器
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('今天', _dateFilter == DateFilterType.today, () {
                  setState(() => _dateFilter = DateFilterType.today);
                  _applyFilters();
                }),
                SizedBox(width: 8.w),
                _buildFilterChip('最近一周', _dateFilter == DateFilterType.lastWeek, () {
                  setState(() => _dateFilter = DateFilterType.lastWeek);
                  _applyFilters();
                }),
                SizedBox(width: 8.w),
                _buildFilterChip('最近一个月', _dateFilter == DateFilterType.lastMonth, () {
                  setState(() => _dateFilter = DateFilterType.lastMonth);
                  _applyFilters();
                }),
                SizedBox(width: 8.w),
                _buildFilterChip('自定义日期', _dateFilter == DateFilterType.custom, () {
                  _showCustomDatePicker();
                }),
                SizedBox(width: 16.w),
                _buildFilterChip('质量良好', _qualityFilter == QualityFilter.good, () {
                  setState(() => _qualityFilter = _qualityFilter == QualityFilter.good 
                      ? QualityFilter.all : QualityFilter.good);
                  _applyFilters();
                }),
                SizedBox(width: 8.w),
                _buildFilterChip('需调整', _qualityFilter == QualityFilter.needsAdjustment, () {
                  setState(() => _qualityFilter = _qualityFilter == QualityFilter.needsAdjustment 
                      ? QualityFilter.all : QualityFilter.needsAdjustment);
                  _applyFilters();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outline.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDataTable() {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // 表格头部
              _buildTableHeader(),
              
              // 表格数据
              if (_filteredData.isEmpty)
                _buildEmptyState()
              else
                ..._buildTableRows(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.r),
          topRight: Radius.circular(12.r),
        ),
      ),
      child: Row(
        children: [
          // 全选复选框
          SizedBox(
            width: 40.w,
            child: Checkbox(
              value: _isSelectAll,
              onChanged: _toggleSelectAll,
            ),
          ),
          
          // 表格列标题
          Expanded(
            flex: 2,
            child: Text(
              '设备/会话信息',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '问题内容',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '召回答案',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '数据质量',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '操作',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTableRows() {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = (startIndex + _itemsPerPage).clamp(0, _filteredData.length);
    final pageData = _filteredData.sublist(startIndex, endIndex);
    
    return pageData.map((item) => _buildTableRow(item)).toList();
  }

  Widget _buildTableRow(TuningDataItem item) {
    final isSelected = _selectedItems.contains(item.id);
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryContainer.withOpacity(0.1) : null,
        border: Border(
          bottom: BorderSide(
            color: AppColors.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 选择复选框
          SizedBox(
            width: 40.w,
            child: Checkbox(
              value: isSelected,
              onChanged: (value) => _toggleItemSelection(item.id),
            ),
          ),
          
          // 设备/会话信息
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '设备: ${item.deviceId}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '会话: ${item.sessionId}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  DateFormat('MM-dd HH:mm').format(item.sessionDate),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          // 问题内容
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.question,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.tags.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 4.w,
                    runSpacing: 4.h,
                    children: item.tags.map((tag) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.onSecondaryContainer,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
          
          // 召回答案
          Expanded(
            flex: 3,
            child: Text(
              item.retrievedAnswer,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColors.onSurface,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // 数据质量
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: item.dataQuality == DataQuality.good 
                    ? AppColors.successContainer 
                    : AppColors.warningContainer,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                item.dataQuality == DataQuality.good ? '良好' : '需调整',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: item.dataQuality == DataQuality.good 
                      ? AppColors.onSuccessContainer 
                      : AppColors.onWarningContainer,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          
          // 操作按钮
          Expanded(
            flex: 1,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () => _showTuningDialog(item),
                  icon: const Icon(Icons.tune),
                  iconSize: 18.sp,
                  tooltip: '调优',
                ),
                IconButton(
                  onPressed: () => _extractFAQ(item),
                  icon: const Icon(Icons.quiz),
                  iconSize: 18.sp,
                  tooltip: 'FAQ提取',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(48.w),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 64.sp,
            color: AppColors.onSurfaceVariant,
          ),
          SizedBox(height: 16.h),
          Text(
            '暂无数据',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '请调整筛选条件或刷新数据',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationSection() {
    if (_totalItems == 0) return const SizedBox.shrink();
    
    final totalPages = (_totalItems / _itemsPerPage).ceil();
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '共 $_totalItems 条数据，第 $_currentPage/$totalPages 页',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          Row(
            children: [
              IconButton(
                onPressed: _currentPage > 1 ? _previousPage : null,
                icon: const Icon(Icons.chevron_left),
              ),
              ...List.generate(
                totalPages.clamp(0, 5),
                (index) {
                  final pageNum = index + 1;
                  return GestureDetector(
                    onTap: () => _goToPage(pageNum),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: pageNum == _currentPage ? AppColors.primary : null,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        pageNum.toString(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: pageNum == _currentPage 
                              ? AppColors.onPrimary 
                              : AppColors.onSurface,
                        ),
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                onPressed: _currentPage < totalPages ? _nextPage : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleSelectAll(bool? value) {
    setState(() {
      _isSelectAll = value ?? false;
      if (_isSelectAll) {
        _selectedItems = _filteredData.map((item) => item.id).toSet();
      } else {
        _selectedItems.clear();
      }
    });
  }

  void _toggleItemSelection(String itemId) {
    setState(() {
      if (_selectedItems.contains(itemId)) {
        _selectedItems.remove(itemId);
      } else {
        _selectedItems.add(itemId);
      }
      _isSelectAll = _selectedItems.length == _filteredData.length;
    });
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() => _currentPage--);
    }
  }

  void _nextPage() {
    final totalPages = (_totalItems / _itemsPerPage).ceil();
    if (_currentPage < totalPages) {
      setState(() => _currentPage++);
    }
  }

  void _goToPage(int page) {
    setState(() => _currentPage = page);
  }

  void _showAdvancedFilters() {
    showDialog(
      context: context,
      builder: (context) => _AdvancedFiltersDialog(
        deviceFilter: _deviceFilter,
        qualityFilter: _qualityFilter,
        onApply: (deviceFilter, qualityFilter) {
          setState(() {
            _deviceFilter = deviceFilter;
            _qualityFilter = qualityFilter;
          });
          _applyFilters();
        },
      ),
    );
  }

  void _showCustomDatePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _customStartDate != null && _customEndDate != null
          ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
          : null,
    );
    
    if (picked != null) {
      setState(() {
        _customStartDate = picked.start;
        _customEndDate = picked.end;
        _dateFilter = DateFilterType.custom;
      });
      _applyFilters();
    }
  }

  void _showTuningDialog(TuningDataItem item) {
    showDialog(
      context: context,
      builder: (context) => _TuningDialog(item: item),
    );
  }

  void _extractFAQ(TuningDataItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('正在提取FAQ: ${item.question}'),
        action: SnackBarAction(
          label: '查看',
          onPressed: () {
            // TODO: 导航到FAQ管理页面
          },
        ),
      ),
    );
  }

  void _showBatchActions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _BatchActionsSheet(
        selectedCount: _selectedItems.length,
        onBatchTuning: _performBatchTuning,
        onBatchFAQExtraction: _performBatchFAQExtraction,
        onBatchExport: _performBatchExport,
      ),
    );
  }

  void _performBatchTuning() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('正在批量调优 ${_selectedItems.length} 条数据...'),
        duration: const Duration(seconds: 3),
      ),
    );
    
    // TODO: 实现批量调优逻辑
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('批量调优完成'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _selectedItems.clear());
        _loadData();
      }
    });
  }

  void _performBatchFAQExtraction() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('正在批量提取FAQ ${_selectedItems.length} 条...'),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // TODO: 实现批量FAQ提取逻辑
  }

  void _performBatchExport() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('正在导出 ${_selectedItems.length} 条数据...'),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // TODO: 实现批量导出逻辑
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('正在导出数据...'),
        duration: Duration(seconds: 2),
      ),
    );
    
    // TODO: 实现数据导出逻辑
  }

  void _refreshData() {
    setState(() {
      _selectedItems.clear();
      _isSelectAll = false;
    });
    _loadData();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('数据已刷新'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

// 高级筛选对话框
class _AdvancedFiltersDialog extends StatefulWidget {
  final String deviceFilter;
  final QualityFilter qualityFilter;
  final Function(String, QualityFilter) onApply;

  const _AdvancedFiltersDialog({
    required this.deviceFilter,
    required this.qualityFilter,
    required this.onApply,
  });

  @override
  State<_AdvancedFiltersDialog> createState() => _AdvancedFiltersDialogState();
}

class _AdvancedFiltersDialogState extends State<_AdvancedFiltersDialog> {
  late String _deviceFilter;
  late QualityFilter _qualityFilter;

  @override
  void initState() {
    super.initState();
    _deviceFilter = widget.deviceFilter;
    _qualityFilter = widget.qualityFilter;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('高级筛选'),
      content: SizedBox(
        width: 300.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              name: 'device_filter',
              label: '设备ID筛选',
              hintText: '输入设备ID关键词',
              initialValue: _deviceFilter,
              onChanged: (value) => _deviceFilter = value ?? '',
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<QualityFilter>(
              value: _qualityFilter,
              decoration: const InputDecoration(
                labelText: '数据质量',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: QualityFilter.all, child: Text('全部')),
                DropdownMenuItem(value: QualityFilter.good, child: Text('质量良好')),
                DropdownMenuItem(value: QualityFilter.needsAdjustment, child: Text('需要调整')),
              ],
              onChanged: (value) => setState(() => _qualityFilter = value!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        CustomButton(
          text: '应用',
          onPressed: () {
            widget.onApply(_deviceFilter, _qualityFilter);
            Navigator.of(context).pop();
          },
          width: 80,
        ),
      ],
    );
  }
}

// 调优对话框
class _TuningDialog extends StatefulWidget {
  final TuningDataItem item;

  const _TuningDialog({required this.item});

  @override
  State<_TuningDialog> createState() => _TuningDialogState();
}

class _TuningDialogState extends State<_TuningDialog> {
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  late TextEditingController _tagsController;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.item.question);
    _answerController = TextEditingController(text: widget.item.retrievedAnswer);
    _tagsController = TextEditingController(text: widget.item.tags.join(', '));
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('调优数据'),
      content: SizedBox(
        width: 400.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              name: 'question',
              controller: _questionController,
              label: '问题内容',
              maxLines: 3,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              name: 'answer',
              controller: _answerController,
              label: '答案内容',
              maxLines: 5,
            ),
            SizedBox(height: 16.h),
            CustomTextField(
              name: 'tags',
              controller: _tagsController,
              label: '标签 (用逗号分隔)',
              hintText: '例如: 权限, 搜索, 配置',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        CustomButton(
          text: '保存调优',
          onPressed: _saveTuning,
          width: 100,
        ),
      ],
    );
  }

  void _saveTuning() {
    // TODO: 实现调优保存逻辑
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('调优数据已保存'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// 批量操作底部表单
class _BatchActionsSheet extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onBatchTuning;
  final VoidCallback onBatchFAQExtraction;
  final VoidCallback onBatchExport;

  const _BatchActionsSheet({
    required this.selectedCount,
    required this.onBatchTuning,
    required this.onBatchFAQExtraction,
    required this.onBatchExport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '批量操作 ($selectedCount 项)',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 24.h),
          
          ListTile(
            leading: const Icon(Icons.auto_fix_high),
            title: const Text('批量调优'),
            subtitle: const Text('对选中的数据进行智能调优'),
            onTap: onBatchTuning,
          ),
          
          ListTile(
            leading: const Icon(Icons.quiz),
            title: const Text('批量FAQ提取'),
            subtitle: const Text('从选中数据中提取FAQ'),
            onTap: onBatchFAQExtraction,
          ),
          
          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('批量导出'),
            subtitle: const Text('导出选中的数据'),
            onTap: onBatchExport,
          ),
          
          SizedBox(height: 16.h),
          
          CustomButton(
            text: '取消',
            onPressed: () => Navigator.of(context).pop(),
            isOutlined: true,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}

// 数据模型和枚举
enum DataMode { client, workspace }

enum DateFilterType { today, lastWeek, lastMonth, custom }

enum QualityFilter { all, good, needsAdjustment }

enum DataQuality { good, needsAdjustment }

class TuningDataItem {
  final String id;
  final String deviceId;
  final String sessionId;
  final DateTime sessionDate;
  final String question;
  final String retrievedAnswer;
  final DataQuality dataQuality;
  final List<String> tags;
  final DataMode mode;

  TuningDataItem({
    required this.id,
    required this.deviceId,
    required this.sessionId,
    required this.sessionDate,
    required this.question,
    required this.retrievedAnswer,
    required this.dataQuality,
    required this.tags,
    required this.mode,
  });
} 