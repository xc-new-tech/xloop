import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/widgets/custom_button.dart';
import '../../../../../shared/widgets/custom_text_field.dart';
import '../../../domain/entities/knowledge_base.dart';

class BasicDocumentPage extends StatefulWidget {
  final KnowledgeBase knowledgeBase;

  const BasicDocumentPage({
    super.key,
    required this.knowledgeBase,
  });

  @override
  State<BasicDocumentPage> createState() => _BasicDocumentPageState();
}

class _BasicDocumentPageState extends State<BasicDocumentPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<DocumentItem> _documents = [];
  bool _isLoading = false;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  void _loadDocuments() {
    setState(() {
      _isLoading = true;
    });
    
    // 模拟加载文档数据
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _documents.addAll([
          DocumentItem(
            id: '1',
            fileName: '产品介绍.pdf',
            originalName: '产品介绍.pdf',
            fileType: DocumentType.pdf,
            fileSize: 2048576, // 2MB
            description: '包含公司主要产品的详细介绍和技术规格说明',
            sliceCount: 15,
            createdBy: '张三',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
            updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          DocumentItem(
            id: '2',
            fileName: '用户手册.docx',
            originalName: '用户操作手册_v2.1.docx',
            fileType: DocumentType.doc,
            fileSize: 1536000, // 1.5MB
            description: '详细的用户操作指南，包含常见问题解答和故障排除方法',
            sliceCount: 23,
            createdBy: '李四',
            createdAt: DateTime.now().subtract(const Duration(days: 3)),
            updatedAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ]);
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchAndFilters(),
            Expanded(
              child: _isLoading ? _buildLoading() : _buildDocumentList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUploadDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.upload_file, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Row(
              children: [
                Icon(
                  Icons.folder_outlined,
                  color: Colors.white,
                  size: 28.w,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '基础文档管理',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '管理各类文档和多媒体文件',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                _buildStatCard('文档总数', '${_documents.length}'),
                SizedBox(width: 12.w),
                _buildStatCard('切片总数', '${_documents.fold(0, (sum, d) => sum + d.sliceCount)}'),
                SizedBox(width: 12.w),
                _buildStatCard('总大小', _formatFileSize(_documents.fold(0, (sum, d) => sum + d.fileSize))),
              ],
            ),
          ],
        ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  name: 'search_documents',
                  controller: _searchController,
                  hintText: '搜索文档名称或描述...',
                  prefixIcon: const Icon(Icons.search),
                  onChanged: (value) => _filterDocuments(value ?? ''),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: IconButton(
                  onPressed: _showSortDialog,
                  icon: Icon(
                    Icons.sort,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('全部', 'all'),
                SizedBox(width: 8.w),
                _buildFilterChip('PDF', 'pdf'),
                SizedBox(width: 8.w),
                _buildFilterChip('文档', 'doc'),
                SizedBox(width: 8.w),
                _buildFilterChip('文本', 'text'),
                SizedBox(width: 8.w),
                _buildFilterChip('音频', 'audio'),
                SizedBox(width: 8.w),
                _buildFilterChip('图片', 'image'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
        _applyFilter();
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildDocumentList() {
    if (_documents.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: _documents.length,
      itemBuilder: (context, index) {
        final document = _documents[index];
        return _buildDocumentCard(document);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_outlined,
            size: 80.w,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 16.h),
          Text(
            '暂无文档',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '点击右下角按钮上传第一个文档',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(DocumentItem document) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _openDocumentDetail(document),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: document.fileType.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      document.fileType.icon,
                      color: document.fileType.color,
                      size: 24.w,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.fileName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          document.originalName,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleDocumentAction(value, document),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'view',
                        child: ListTile(
                          leading: Icon(Icons.visibility),
                          title: Text('查看详情'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'download',
                        child: ListTile(
                          leading: Icon(Icons.download),
                          title: Text('下载'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'rename',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('重命名'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('删除', style: TextStyle(color: Colors.red)),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                document.description,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  _buildInfoChip(
                    icon: Icons.description_outlined,
                    label: '${document.sliceCount} 个切片',
                  ),
                  SizedBox(width: 12.w),
                  _buildInfoChip(
                    icon: Icons.storage,
                    label: _formatFileSize(document.fileSize),
                  ),
                  SizedBox(width: 12.w),
                  _buildInfoChip(
                    icon: Icons.access_time,
                    label: _formatDate(document.updatedAt),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 14.w,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    document.createdBy,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'ID: ${document.id}',
                    style: TextStyle(
                      fontSize: 12.sp,
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

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12.w,
            color: AppColors.primary,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return '今天';
    } else if (difference.inDays == 1) {
      return '昨天';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${date.month}/${date.day}';
    }
  }

  void _filterDocuments(String query) {
    // TODO: 实现文档搜索过滤
  }

  void _applyFilter() {
    // TODO: 根据选择的过滤器筛选文档
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('排序方式'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('按名称排序'),
              leading: const Icon(Icons.sort_by_alpha),
              onTap: () {
                Navigator.pop(context);
                // TODO: 实现按名称排序
              },
            ),
            ListTile(
              title: const Text('按大小排序'),
              leading: const Icon(Icons.storage),
              onTap: () {
                Navigator.pop(context);
                // TODO: 实现按大小排序
              },
            ),
            ListTile(
              title: const Text('按时间排序'),
              leading: const Icon(Icons.access_time),
              onTap: () {
                Navigator.pop(context);
                // TODO: 实现按时间排序
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('上传文档'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('支持上传以下格式的文件：'),
            SizedBox(height: 8.h),
            const Text('• PDF、DOC、DOCX、TXT'),
            const Text('• CSV、PPT、PPTX'),
            const Text('• MP3、WAV、M4A'),
            const Text('• JPG、PNG、GIF'),
            SizedBox(height: 16.h),
            const Text('单个文件不超过50MB'),
            SizedBox(height: 16.h),
            CustomButton(
              text: '选择文件',
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('文件上传功能开发中...')),
                );
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

  void _openDocumentDetail(DocumentItem document) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看文档详情: ${document.fileName}')),
    );
  }

  void _handleDocumentAction(String action, DocumentItem document) {
    switch (action) {
      case 'view':
        _openDocumentDetail(document);
        break;
      case 'download':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('正在下载: ${document.fileName}')),
        );
        break;
      case 'rename':
        _showRenameDialog(document);
        break;
      case 'delete':
        _showDeleteConfirmDialog(document);
        break;
    }
  }

  void _showRenameDialog(DocumentItem document) {
    final controller = TextEditingController(text: document.fileName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重命名文档'),
        content: CustomTextField(
          name: 'rename_document',
          controller: controller,
          label: '文档名称',
          hintText: '请输入新的文档名称',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          CustomButton(
            text: '确定',
            onPressed: () {
              if (controller.text.isNotEmpty && controller.text != document.fileName) {
                setState(() {
                  final index = _documents.indexOf(document);
                  _documents[index] = document.copyWith(fileName: controller.text);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('文档重命名成功')),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(DocumentItem document) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除文档 "${document.fileName}" 吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _documents.remove(document);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已删除文档: ${document.fileName}')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

// 文档数据模型
class DocumentItem {
  final String id;
  final String fileName;
  final String originalName;
  final DocumentType fileType;
  final int fileSize;
  final String description;
  final int sliceCount;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  DocumentItem({
    required this.id,
    required this.fileName,
    required this.originalName,
    required this.fileType,
    required this.fileSize,
    required this.description,
    required this.sliceCount,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  DocumentItem copyWith({
    String? id,
    String? fileName,
    String? originalName,
    DocumentType? fileType,
    int? fileSize,
    String? description,
    int? sliceCount,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DocumentItem(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      originalName: originalName ?? this.originalName,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      description: description ?? this.description,
      sliceCount: sliceCount ?? this.sliceCount,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum DocumentType {
  pdf,
  doc,
  text,
  audio,
  image,
  other,
}

extension DocumentTypeExtension on DocumentType {
  IconData get icon {
    switch (this) {
      case DocumentType.pdf:
        return Icons.picture_as_pdf;
      case DocumentType.doc:
        return Icons.description;
      case DocumentType.text:
        return Icons.text_snippet;
      case DocumentType.audio:
        return Icons.audiotrack;
      case DocumentType.image:
        return Icons.image;
      case DocumentType.other:
        return Icons.insert_drive_file;
    }
  }

  Color get color {
    switch (this) {
      case DocumentType.pdf:
        return Colors.red;
      case DocumentType.doc:
        return Colors.blue;
      case DocumentType.text:
        return Colors.grey;
      case DocumentType.audio:
        return Colors.orange;
      case DocumentType.image:
        return Colors.green;
      case DocumentType.other:
        return Colors.purple;
    }
  }
} 