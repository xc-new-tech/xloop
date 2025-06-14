import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/file_upload_widget.dart';

/// 文件管理页面
class FileManagementPage extends StatefulWidget {
  final String? knowledgeBaseId;
  
  const FileManagementPage({
    super.key,
    this.knowledgeBaseId,
  });

  @override
  State<FileManagementPage> createState() => _FileManagementPageState();
}

class _FileManagementPageState extends State<FileManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<File> _selectedFiles = [];
  List<FileItem> _uploadedFiles = [];
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUploadedFiles();
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
        title: const Text('文件管理'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.cloud_upload),
              text: '上传文件',
            ),
            Tab(
              icon: Icon(Icons.folder),
              text: '文件库',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUploadTab(),
          _buildFileLibraryTab(),
        ],
      ),
    );
  }

  /// 构建上传页面
  Widget _buildUploadTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 上传说明
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '文件上传说明',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '• 支持多种文件格式：PDF、Word、Excel、PowerPoint、图片等\n'
                    '• 单个文件大小不超过100MB\n'
                    '• 支持批量上传，最多20个文件\n'
                    '• 上传的文件将用于知识库构建和检索',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 文件上传组件
          FileUploadWidget(
            onFilesSelected: _onFilesSelected,
            allowedExtensions: const [
              'pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx',
              'txt', 'md', 'jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'
            ],
            maxFiles: 20,
            maxSizeInMB: 100,
            helpText: '支持PDF、Office文档、图片等格式',
          ),

          // 上传进度
          if (_isUploading) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: _uploadProgress,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '正在上传文件...',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(_uploadProgress * 100).toInt()}%',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _uploadProgress,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // 上传按钮
          if (_selectedFiles.isNotEmpty && !_isUploading) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _uploadFiles,
                icon: const Icon(Icons.cloud_upload),
                label: Text('上传 ${_selectedFiles.length} 个文件'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 构建文件库页面
  Widget _buildFileLibraryTab() {
    return Column(
      children: [
        // 搜索和筛选栏
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.border, width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '搜索文件...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.border),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _showFilterDialog,
                icon: const Icon(Icons.filter_list),
                tooltip: '筛选',
              ),
              IconButton(
                onPressed: _refreshFileList,
                icon: const Icon(Icons.refresh),
                tooltip: '刷新',
              ),
            ],
          ),
        ),

        // 文件列表
        Expanded(
          child: _uploadedFiles.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _uploadedFiles.length,
                  itemBuilder: (context, index) {
                    final file = _uploadedFiles[index];
                    return _buildFileCard(file, index);
                  },
                ),
        ),
      ],
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: AppColors.iconSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            '暂无文件',
            style: AppTextStyles.titleMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '请先上传一些文件到知识库',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _tabController.animateTo(0),
            icon: const Icon(Icons.cloud_upload),
            label: const Text('上传文件'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建文件卡片
  Widget _buildFileCard(FileItem file, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Icon(
            _getFileIcon(file.extension),
            color: AppColors.primary,
          ),
        ),
        title: Text(
          file.name,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${file.size} • ${file.uploadDate}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (file.description != null) ...[
              const SizedBox(height: 4),
              Text(
                file.description!,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _onFileMenuSelected(value, file),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'preview',
              child: ListTile(
                leading: Icon(Icons.visibility),
                title: Text('预览'),
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
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('编辑信息'),
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
        ),
        onTap: () => _previewFile(file),
      ),
    );
  }

  /// 文件选择回调
  void _onFilesSelected(List<File> files) {
    setState(() {
      _selectedFiles = files;
    });
  }

  /// 上传文件
  Future<void> _uploadFiles() async {
    if (_selectedFiles.isEmpty) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // 模拟上传过程
      for (int i = 0; i < _selectedFiles.length; i++) {
        final file = _selectedFiles[i];
        
        // 模拟上传进度
        await _simulateUpload(file, (progress) {
          setState(() {
            _uploadProgress = (i + progress) / _selectedFiles.length;
          });
        });

        // 添加到已上传文件列表
        _uploadedFiles.add(FileItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: file.path.split('/').last,
          extension: file.path.split('.').last.toLowerCase(),
          size: _formatFileSize(file.lengthSync()),
          uploadDate: _formatDate(DateTime.now()),
          description: null,
        ));
      }

      // 上传完成
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
        _selectedFiles.clear();
      });

      // 切换到文件库页面
      _tabController.animateTo(1);

      // 显示成功消息
      _showSuccessMessage('成功上传 ${_selectedFiles.length} 个文件');
    } catch (e) {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
      _showErrorMessage('上传失败：$e');
    }
  }

  /// 模拟上传进度
  Future<void> _simulateUpload(File file, Function(double) onProgress) async {
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 50));
      onProgress(i / 100);
    }
  }

  /// 加载已上传文件
  void _loadUploadedFiles() {
    // 模拟一些示例文件
    _uploadedFiles = [
      FileItem(
        id: '1',
        name: 'XLoop产品需求文档.pdf',
        extension: 'pdf',
        size: '2.5MB',
        uploadDate: '2025-01-10',
        description: 'XLoop知识智能平台的完整产品需求文档',
      ),
      FileItem(
        id: '2',
        name: '技术架构设计.docx',
        extension: 'docx',
        size: '1.8MB',
        uploadDate: '2025-01-10',
        description: '系统技术架构和设计方案',
      ),
      FileItem(
        id: '3',
        name: 'API接口文档.xlsx',
        extension: 'xlsx',
        size: '856KB',
        uploadDate: '2025-01-09',
        description: 'RESTful API接口设计文档',
      ),
    ];
  }

  /// 搜索文件
  void _onSearchChanged(String query) {
    // TODO: 实现搜索功能
  }

  /// 显示筛选对话框
  void _showFilterDialog() {
    // TODO: 实现筛选功能
  }

  /// 刷新文件列表
  void _refreshFileList() {
    _loadUploadedFiles();
    setState(() {});
  }

  /// 文件菜单选择
  void _onFileMenuSelected(String action, FileItem file) {
    switch (action) {
      case 'preview':
        _previewFile(file);
        break;
      case 'download':
        _downloadFile(file);
        break;
      case 'edit':
        _editFile(file);
        break;
      case 'delete':
        _deleteFile(file);
        break;
    }
  }

  /// 预览文件
  void _previewFile(FileItem file) {
    // TODO: 实现文件预览
    _showInfoMessage('预览文件：${file.name}');
  }

  /// 下载文件
  void _downloadFile(FileItem file) {
    // TODO: 实现文件下载
    _showInfoMessage('下载文件：${file.name}');
  }

  /// 编辑文件信息
  void _editFile(FileItem file) {
    // TODO: 实现文件信息编辑
    _showInfoMessage('编辑文件：${file.name}');
  }

  /// 删除文件
  void _deleteFile(FileItem file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除文件"${file.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _uploadedFiles.removeWhere((f) => f.id == file.id);
              });
              _showSuccessMessage('文件已删除');
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// 获取文件图标
  IconData _getFileIcon(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
      case 'md':
        return Icons.text_snippet;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  /// 格式化文件大小
  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 显示成功消息
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  /// 显示错误消息
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  /// 显示信息消息
  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
      ),
    );
  }
}

/// 文件项数据模型
class FileItem {
  final String id;
  final String name;
  final String extension;
  final String size;
  final String uploadDate;
  final String? description;

  FileItem({
    required this.id,
    required this.name,
    required this.extension,
    required this.size,
    required this.uploadDate,
    this.description,
  });
} 