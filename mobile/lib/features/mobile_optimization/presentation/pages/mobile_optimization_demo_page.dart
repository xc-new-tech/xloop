import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/responsive_utils.dart';
import '../../../../core/utils/gesture_utils.dart';
import '../../../../core/utils/mobile_file_utils.dart';
import '../../../../core/utils/performance_utils.dart';
import '../../../../shared/widgets/adaptive_layout.dart';

/// 移动端优化演示页面
class MobileOptimizationDemoPage extends StatefulWidget {
  const MobileOptimizationDemoPage({super.key});

  @override
  State<MobileOptimizationDemoPage> createState() => _MobileOptimizationDemoPageState();
}

class _MobileOptimizationDemoPageState extends State<MobileOptimizationDemoPage>
    with PerformanceMonitorMixin {
  int _selectedTabIndex = 0;
  final List<String> _demoImages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    PerformanceUtils.enablePerformanceMonitoring();
  }

  @override
  void dispose() {
    PerformanceUtils.disablePerformanceMonitoring();
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '移动端优化演示',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showPerformanceReport,
            icon: Icon(Icons.analytics, size: 24.w),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: _buildTabContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['响应式布局', '手势操作', '文件处理', '性能优化'];
    
    return Container(
      height: 48.h,
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;
          final isSelected = _selectedTabIndex == index;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isSelected ? Colors.white : Colors.grey[600],
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildResponsiveLayoutDemo();
      case 1:
        return _buildGestureDemo();
      case 2:
        return _buildFileHandlingDemo();
      case 3:
        return _buildPerformanceDemo();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildResponsiveLayoutDemo() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '响应式布局演示',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          
          // 设备信息卡片
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '设备信息',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text('屏幕宽度: ${MediaQuery.of(context).size.width.toStringAsFixed(1)}'),
                  Text('屏幕高度: ${MediaQuery.of(context).size.height.toStringAsFixed(1)}'),
                  Text('像素密度: ${MediaQuery.of(context).devicePixelRatio.toStringAsFixed(1)}'),
                ],
              ),
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // 自适应网格演示
          Text(
            '自适应网格',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
              crossAxisSpacing: 8.w,
              mainAxisSpacing: 8.h,
              childAspectRatio: 1.2,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.widgets,
                      size: 32.w,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '项目 ${index + 1}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGestureDemo() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '手势操作演示',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          
          // 手势识别演示
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '手势识别',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  
                  Container(
                    width: double.infinity,
                    height: 200.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: GestureDetector(
                      onTap: () => _showSnackBar('单击'),
                      onDoubleTap: () => _showSnackBar('双击'),
                      onLongPress: () => _showSnackBar('长按'),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.touch_app, size: 48, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              '在这里尝试不同的手势\n单击、双击、长按',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileHandlingDemo() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '文件处理演示',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          
          // 文件选择按钮
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: () => _showSnackBar('文件选择功能'),
              icon: const Icon(Icons.folder_open),
              label: const Text('选择文件'),
            ),
          ),
          
          SizedBox(height: 8.h),
          
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: OutlinedButton.icon(
              onPressed: () => _showSnackBar('拍照功能'),
              icon: const Icon(Icons.camera_alt),
              label: const Text('拍照'),
            ),
          ),
          
          SizedBox(height: 8.h),
          
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: OutlinedButton.icon(
              onPressed: () => _showSnackBar('相册选择功能'),
              icon: const Icon(Icons.photo_library),
              label: const Text('从相册选择'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceDemo() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '性能优化演示',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          
          // 性能测试按钮
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _runPerformanceTest,
              icon: _isLoading 
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.speed),
              label: Text(_isLoading ? '运行中...' : '运行性能测试'),
            ),
          ),
          
          SizedBox(height: 8.h),
          
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: OutlinedButton.icon(
              onPressed: _showPerformanceReport,
              icon: const Icon(Icons.analytics),
              label: const Text('查看性能报告'),
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // 优化列表演示
          Text(
            '优化列表',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          
          SizedBox(
            height: 300.h,
            child: ListView.builder(
              itemCount: 50,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text('优化列表项 ${index + 1}'),
                  subtitle: const Text('这是一个性能优化的列表项'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showSnackBar('点击了列表项 ${index + 1}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runPerformanceTest() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 模拟性能测试
      await Future.delayed(const Duration(seconds: 2));
      _showSnackBar('性能测试完成');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showPerformanceReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('性能报告'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('总指标数: 100'),
            Text('平均响应时间: 50ms'),
            Text('峰值内存使用: 120MB'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
} 