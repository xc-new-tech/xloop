import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Simplified FAQ management page - works independently without BLoC complexity
class FaqManagementSimplePage extends StatefulWidget {
  final String? knowledgeBaseId;
  
  const FaqManagementSimplePage({
    super.key,
    this.knowledgeBaseId,
  });

  @override
  State<FaqManagementSimplePage> createState() => _FaqManagementSimplePageState();
}

class _FaqManagementSimplePageState extends State<FaqManagementSimplePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Simple mock data to demonstrate functionality
  final List<Map<String, dynamic>> _mockFaqs = [
    {
      'id': '1',
      'question': 'How to create a knowledge base?',
      'answer': 'Click the "Create Knowledge Base" button and fill in the required information.',
      'category': 'User Guide',
      'status': 'published',
      'viewCount': 120,
      'likeCount': 15,
      'createdAt': DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      'id': '2', 
      'question': 'How to upload files to knowledge base?',
      'answer': 'In the knowledge base details page, click "Upload Files" and select files.',
      'category': 'File Management',
      'status': 'published',
      'viewCount': 89,
      'likeCount': 8,
      'createdAt': DateTime.now().subtract(const Duration(days: 3)),
    },
    {
      'id': '3',
      'question': 'How to search knowledge base content?',
      'answer': 'Use the search bar to enter keywords and the system will search related documents and FAQs.',
      'category': 'Search',
      'status': 'draft',
      'viewCount': 45,
      'likeCount': 3,
      'createdAt': DateTime.now().subtract(const Duration(days: 1)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQ Management'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'FAQ List'),
            Tab(text: 'Analytics'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateFaqDialog,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFaqListTab(),
          _buildAnalyticsTab(),
        ],
      ),
    );
  }

  Widget _buildFaqListTab() {
    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search FAQs...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        
        // FAQ list
        Expanded(
          child: ListView.builder(
            itemCount: _mockFaqs.length,
            itemBuilder: (context, index) {
              final faq = _mockFaqs[index];
              return _buildFaqCard(faq);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFaqCard(Map<String, dynamic> faq) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showFaqDetailDialog(faq),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question title and status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      faq['question'] as String,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _buildStatusChip(faq['status'] as String),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Answer preview
              Text(
                faq['answer'] as String,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Metadata
              Row(
                children: [
                  Icon(
                    Icons.folder_outlined,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    faq['category'] as String,
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.visibility_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${faq['viewCount']}',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.thumb_up_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${faq['likeCount']}',
                    style: AppTextStyles.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    '${DateTime.now().difference(faq['createdAt'] as DateTime).inDays} days ago',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = status == 'published' ? Colors.green : Colors.orange;
    String label = status == 'published' ? 'Published' : 'Draft';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    final totalFaqs = _mockFaqs.length;
    final publishedFaqs = _mockFaqs.where((f) => f['status'] == 'published').length;
    final totalViews = _mockFaqs.fold<int>(0, (sum, faq) => sum + (faq['viewCount'] as int));
    final totalLikes = _mockFaqs.fold<int>(0, (sum, faq) => sum + (faq['likeCount'] as int));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Statistics cards
          Row(
            children: [
              Expanded(child: _buildStatCard('Total FAQs', '$totalFaqs', Icons.quiz_outlined, AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Published', '$publishedFaqs', Icons.check_circle_outline, Colors.green)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('Total Views', '$totalViews', Icons.visibility_outlined, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('Total Likes', '$totalLikes', Icons.thumb_up_outlined, Colors.orange)),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Category statistics
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FAQ Categories',
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ..._getCategories().map((category) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          category['name'] as String,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                      Text(
                        '${category['count']} FAQs',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getCategories() {
    final categoryCount = <String, int>{};
    for (final faq in _mockFaqs) {
      final category = faq['category'] as String;
      categoryCount[category] = (categoryCount[category] ?? 0) + 1;
    }
    return categoryCount.entries
        .map((e) => {'name': e.key, 'count': e.value})
        .toList();
  }

  void _showCreateFaqDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create FAQ'),
        content: const Text('FAQ creation feature is in development. Please use the full FAQ management module for creation capabilities.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFaqDetailDialog(Map<String, dynamic> faq) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          constraints: const BoxConstraints(maxHeight: 500),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'FAQ Details',
                      style: AppTextStyles.titleLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              
              const Divider(),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        faq['question'] as String,
                        style: AppTextStyles.bodyLarge,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        'Answer',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        faq['answer'] as String,
                        style: AppTextStyles.bodyLarge,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        'Category',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        faq['category'] as String,
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 