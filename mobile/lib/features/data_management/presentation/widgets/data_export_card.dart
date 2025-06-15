import 'package:flutter/material.dart';

/// 数据导出卡片
class DataExportCard extends StatelessWidget {
  final VoidCallback? onExportAll;
  final VoidCallback? onExportKnowledgeBases;
  final VoidCallback? onExportConversations;
  final VoidCallback? onExportDocuments;

  const DataExportCard({
    super.key,
    this.onExportAll,
    this.onExportKnowledgeBases,
    this.onExportConversations,
    this.onExportDocuments,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.download, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  '数据导出',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              '选择要导出的数据类型',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            
            const SizedBox(height: 16),
            
            _buildExportOption(
              context,
              '导出全部数据',
              '包含所有知识库、文档和对话记录',
              Icons.all_inclusive,
              onExportAll,
            ),
            
            const SizedBox(height: 12),
            
            _buildExportOption(
              context,
              '导出知识库',
              '仅导出知识库结构和配置',
              Icons.library_books,
              onExportKnowledgeBases,
            ),
            
            const SizedBox(height: 12),
            
            _buildExportOption(
              context,
              '导出文档',
              '仅导出上传的文档文件',
              Icons.description,
              onExportDocuments,
            ),
            
            const SizedBox(height: 12),
            
            _buildExportOption(
              context,
              '导出对话记录',
              '仅导出聊天对话历史',
              Icons.chat,
              onExportConversations,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportOption(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }
} 