import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../shared/presentation/widgets/custom_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../bloc/user_journey_bloc.dart';
import '../bloc/user_journey_event.dart';
import '../bloc/user_journey_state.dart';

class UserJourneyPage extends StatefulWidget {
  const UserJourneyPage({super.key});

  @override
  State<UserJourneyPage> createState() => _UserJourneyPageState();
}

class _UserJourneyPageState extends State<UserJourneyPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final String _currentUserId = 'user_123'; // 模拟用户ID

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // 加载当前旅程
    context.read<UserJourneyBloc>().add(LoadCurrentJourneyEvent(_currentUserId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '用户旅程',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<UserJourneyBloc>().add(
                LoadCurrentJourneyEvent(_currentUserId),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '当前旅程'),
            Tab(text: '历史记录'),
            Tab(text: '统计分析'),
          ],
        ),
      ),
      body: BlocConsumer<UserJourneyBloc, UserJourneyState>(
        listener: (context, state) {
          if (state is UserJourneyError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildCurrentJourneyTab(state),
              _buildHistoryTab(state),
              _buildStatsTab(state),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateJourneyDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildCurrentJourneyTab(UserJourneyState state) {
    if (state is UserJourneyLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore,
            size: 64.w,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            '还没有开始旅程',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '创建您的第一个旅程开始体验',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 24.h),
          CustomButton(
            text: '开始新手引导',
            onPressed: () => _createJourney('onboarding'),
            width: 200.w,
          ),
          SizedBox(height: 12.h),
          CustomButton(
            text: '创建知识库',
            onPressed: () => _createJourney('knowledge_creation'),
            isOutlined: true,
            width: 200.w,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(UserJourneyState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64.w,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            '暂无历史记录',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsTab(UserJourneyState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.analytics,
            size: 64.w,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            '暂无统计数据',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  void _createJourney(String journeyType) {
    context.read<UserJourneyBloc>().add(
      CreateJourneyEvent(
        userId: _currentUserId,
        journeyType: journeyType,
      ),
    );
  }

  void _showCreateJourneyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('创建新旅程'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('新手引导'),
              subtitle: const Text('完整的平台使用指导'),
              onTap: () {
                Navigator.pop(context);
                _createJourney('onboarding');
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books),
              title: const Text('知识库创建'),
              subtitle: const Text('创建和管理知识库'),
              onTap: () {
                Navigator.pop(context);
                _createJourney('knowledge_creation');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }
} 