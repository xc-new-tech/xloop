import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 简化的文件上传组件
class FileUploadWidget extends StatefulWidget {
  final Function(List<File>)? onFilesSelected;
  final List<String>? allowedExtensions;
  final int? maxFiles;
  final double? maxSizeInMB;
  final bool multipleFiles;
  final String? helpText;

  const FileUploadWidget({
    super.key,
    this.onFilesSelected,
    this.allowedExtensions,
    this.maxFiles,
    this.maxSizeInMB,
    this.multipleFiles = true,
    this.helpText,
  });

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  List<File> _selectedFiles = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 文件选择区域
        GestureDetector(
          onTap: _selectFiles,
          child: DottedBorder(
            color: AppColors.border,
            strokeWidth: 2,
            dashPattern: const [8, 4],
            borderType: BorderType.RRect,
            radius: const Radius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 48,
                    color: AppColors.iconSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '点击选择文件或拖拽文件到此处',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (widget.helpText != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.helpText!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textHint,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 8),
                  _buildFileRequirements(),
                ],
              ),
            ),
          ),
        ),

        // 已选择的文件列表
        if (_selectedFiles.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            '已选择文件 (${_selectedFiles.length})',
            style: AppTextStyles.titleSmall,
          ),
          const SizedBox(height: 8),
          ..._selectedFiles.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return _buildFileItem(file, index);
          }),
        ],
      ],
    );
  }

  /// 构建文件要求说明
  Widget _buildFileRequirements() {
    final requirements = <String>[];
    
    if (widget.allowedExtensions != null) {
      requirements.add('支持格式：${widget.allowedExtensions!.join(', ')}');
    }
    
    if (widget.maxSizeInMB != null) {
      requirements.add('单个文件不超过 ${widget.maxSizeInMB}MB');
    }
    
    if (widget.maxFiles != null) {
      requirements.add('最多选择 ${widget.maxFiles} 个文件');
    }

    if (requirements.isEmpty) return const SizedBox.shrink();

    return Text(
      requirements.join(' • '),
      style: AppTextStyles.bodySmall.copyWith(
        color: AppColors.textHint,
      ),
      textAlign: TextAlign.center,
    );
  }

  /// 构建文件项
  Widget _buildFileItem(File file, int index) {
    final fileName = file.path.split('/').last;
    final fileSize = file.lengthSync();
    final fileSizeText = _formatFileSize(fileSize);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // 文件图标
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getFileIcon(fileName),
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          
          // 文件信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  fileSizeText,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // 删除按钮
          IconButton(
            onPressed: () => _removeFile(index),
            icon: const Icon(Icons.close),
            iconSize: 20,
            color: AppColors.textSecondary,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  /// 选择文件
  Future<void> _selectFiles() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: widget.multipleFiles,
        type: widget.allowedExtensions != null 
            ? FileType.custom 
            : FileType.any,
        allowedExtensions: widget.allowedExtensions,
      );

      if (result != null) {
        final files = result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();

        if (_validateFiles(files)) {
          setState(() {
            if (widget.multipleFiles) {
              _selectedFiles.addAll(files);
              // 检查最大文件数限制
              if (widget.maxFiles != null && _selectedFiles.length > widget.maxFiles!) {
                _selectedFiles = _selectedFiles.take(widget.maxFiles!).toList();
              }
            } else {
              _selectedFiles = [files.first];
            }
          });
          
          widget.onFilesSelected?.call(_selectedFiles);
        }
      }
    } catch (e) {
      _showErrorMessage('选择文件时出错：$e');
    }
  }

  /// 验证文件
  bool _validateFiles(List<File> files) {
    for (final file in files) {
      // 检查文件大小
      if (widget.maxSizeInMB != null) {
        final sizeInMB = file.lengthSync() / (1024 * 1024);
        if (sizeInMB > widget.maxSizeInMB!) {
          _showErrorMessage('文件 ${file.path.split('/').last} 超过大小限制');
          return false;
        }
      }
    }
    return true;
  }

  /// 移除文件
  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
    widget.onFilesSelected?.call(_selectedFiles);
  }

  /// 获取文件图标
  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    
    switch (extension) {
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
        return Icons.text_snippet;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return Icons.image;
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'flac':
        return Icons.audio_file;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
        return Icons.video_file;
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

  /// 显示错误消息
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }
} 