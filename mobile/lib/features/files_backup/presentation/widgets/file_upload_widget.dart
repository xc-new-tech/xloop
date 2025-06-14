import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:mime/mime.dart';

import '../bloc/file_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/file_constants.dart';

/// 文件上传组件
class FileUploadWidget extends StatefulWidget {
  final List<String>? allowedExtensions;
  final int? maxFileSize; // in bytes
  final int? maxFiles;
  final bool allowMultiple;
  final String? knowledgeBaseId;
  final VoidCallback? onUploadComplete;
  final ValueChanged<List<PlatformFile>>? onFilesSelected;

  const FileUploadWidget({
    super.key,
    this.allowedExtensions,
    this.maxFileSize,
    this.maxFiles,
    this.allowMultiple = true,
    this.knowledgeBaseId,
    this.onUploadComplete,
    this.onFilesSelected,
  });

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  final List<PlatformFile> _selectedFiles = [];
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<FileBloc, FileState>(
      listener: (context, state) {
        if (state is FileUploadSuccess) {
          _showSuccessMessage('文件上传成功');
          _clearSelectedFiles();
          widget.onUploadComplete?.call();
        } else if (state is FileError) {
          _showErrorMessage(state.message);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildUploadArea(),
          if (_selectedFiles.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSelectedFilesList(),
            const SizedBox(height: 16),
            _buildUploadActions(),
          ],
        ],
      ),
    );
  }

  Widget _buildUploadArea() {
    return BlocBuilder<FileBloc, FileState>(
      builder: (context, state) {
        final isUploading = state is FileLoading;
        
        return GestureDetector(
          onTap: isUploading ? null : _selectFiles,
          child: DragTarget<List<PlatformFile>>(
            onWillAccept: (data) => !isUploading,
            onAccept: (files) {
              setState(() {
                _isDragOver = false;
              });
              _handleSelectedFiles(files);
            },
            onLeave: (data) {
              setState(() {
                _isDragOver = false;
              });
            },
            builder: (context, candidateData, rejectedData) {
              return DottedBorder(
                color: _isDragOver 
                    ? AppColors.primary 
                    : AppColors.border,
                strokeWidth: 2,
                dashPattern: const [8, 4],
                borderType: BorderType.RRect,
                radius: const Radius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: _isDragOver 
                        ? AppColors.primary.withOpacity(0.05)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isDragOver ? Icons.cloud_upload : Icons.cloud_upload_outlined,
                        size: 64,
                        color: _isDragOver 
                            ? AppColors.primary 
                            : AppColors.iconSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isUploading 
                            ? '上传中...' 
                            : _isDragOver 
                                ? '释放文件以上传'
                                : '点击选择文件或拖拽文件到此处',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: _isDragOver 
                              ? AppColors.primary 
                              : AppColors.textSecondary,
                          fontWeight: _isDragOver ? FontWeight.w600 : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _buildSupportText(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (isUploading) ...[
                        const SizedBox(height: 16),
                        const CircularProgressIndicator(),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSelectedFilesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '已选择的文件 (${_selectedFiles.length})',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedFiles.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final file = _selectedFiles[index];
              return _buildFileItem(file, index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFileItem(PlatformFile file, int index) {
    final fileSize = _formatFileSize(file.size);
    final fileIcon = _getFileIcon(file.extension);
    
    return ListTile(
      leading: Icon(
        fileIcon,
        color: AppColors.primary,
      ),
      title: Text(
        file.name,
        style: AppTextStyles.bodyMedium,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        fileSize,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      trailing: IconButton(
        onPressed: () => _removeFile(index),
        icon: const Icon(
          Icons.close,
          color: AppColors.error,
          size: 20,
        ),
        tooltip: '移除文件',
      ),
    );
  }

  Widget _buildUploadActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _clearSelectedFiles,
            icon: const Icon(Icons.clear_all),
            label: const Text('清空'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _selectedFiles.isNotEmpty ? _uploadFiles : null,
            icon: const Icon(Icons.cloud_upload),
            label: const Text('上传文件'),
          ),
        ),
      ],
    );
  }

  String _buildSupportText() {
    final extensions = widget.allowedExtensions?.join(', ') ?? 
        FileConstants.supportedExtensions.join(', ');
    final maxSize = widget.maxFileSize ?? FileConstants.maxFileSize;
    final maxSizeText = _formatFileSize(maxSize);
    
    return '支持格式: $extensions\n最大文件大小: $maxSizeText';
  }

  IconData _getFileIcon(String? extension) {
    if (extension == null) return Icons.insert_drive_file;
    
    switch (extension.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_fields;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'mp3':
      case 'wav':
      case 'aac':
        return Icons.audio_file;
      case 'mp4':
      case 'avi':
      case 'mov':
        return Icons.video_file;
      case 'zip':
      case 'rar':
      case '7z':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  Future<void> _selectFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: widget.allowMultiple,
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions ?? FileConstants.supportedExtensions,
      );

      if (result != null) {
        _handleSelectedFiles(result.files);
      }
    } catch (e) {
      _showErrorMessage('文件选择失败: $e');
    }
  }

  void _handleSelectedFiles(List<PlatformFile> files) {
    final validFiles = <PlatformFile>[];
    final errors = <String>[];

    for (final file in files) {
      // 检查文件大小
      if (widget.maxFileSize != null && file.size > widget.maxFileSize!) {
        errors.add('${file.name}: 文件过大');
        continue;
      }

      // 检查文件扩展名
      if (widget.allowedExtensions != null && 
          !widget.allowedExtensions!.contains(file.extension?.toLowerCase())) {
        errors.add('${file.name}: 不支持的文件类型');
        continue;
      }

      // 检查是否已选择
      if (_selectedFiles.any((f) => f.name == file.name && f.size == file.size)) {
        errors.add('${file.name}: 文件已选择');
        continue;
      }

      validFiles.add(file);
    }

    // 检查文件总数
    if (widget.maxFiles != null && 
        _selectedFiles.length + validFiles.length > widget.maxFiles!) {
      final allowed = widget.maxFiles! - _selectedFiles.length;
      validFiles.removeRange(allowed, validFiles.length);
      errors.add('最多只能选择 ${widget.maxFiles} 个文件');
    }

    setState(() {
      _selectedFiles.addAll(validFiles);
    });

    widget.onFilesSelected?.call(_selectedFiles);

    if (errors.isNotEmpty) {
      _showErrorMessage(errors.join('\n'));
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
    widget.onFilesSelected?.call(_selectedFiles);
  }

  void _clearSelectedFiles() {
    setState(() {
      _selectedFiles.clear();
    });
    widget.onFilesSelected?.call(_selectedFiles);
  }

  void _uploadFiles() {
    if (_selectedFiles.isEmpty) return;

    final fileBloc = context.read<FileBloc>();
    fileBloc.add(UploadFilesEvent(
      files: _selectedFiles,
      knowledgeBaseId: widget.knowledgeBaseId,
    ));
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}

/// 文件选择器对话框
class FilePickerDialog extends StatefulWidget {
  final List<String>? allowedExtensions;
  final int? maxFileSize;
  final int? maxFiles;
  final bool allowMultiple;
  final String? knowledgeBaseId;

  const FilePickerDialog({
    super.key,
    this.allowedExtensions,
    this.maxFileSize,
    this.maxFiles,
    this.allowMultiple = true,
    this.knowledgeBaseId,
  });

  @override
  State<FilePickerDialog> createState() => _FilePickerDialogState();
}

class _FilePickerDialogState extends State<FilePickerDialog> {
  List<PlatformFile> _selectedFiles = [];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.cloud_upload,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  '上传文件',
                  style: AppTextStyles.headlineSmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Flexible(
              child: FileUploadWidget(
                allowedExtensions: widget.allowedExtensions,
                maxFileSize: widget.maxFileSize,
                maxFiles: widget.maxFiles,
                allowMultiple: widget.allowMultiple,
                knowledgeBaseId: widget.knowledgeBaseId,
                onFilesSelected: (files) {
                  setState(() {
                    _selectedFiles = files;
                  });
                },
                onUploadComplete: () {
                  Navigator.of(context).pop(true);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 显示文件选择器对话框
Future<bool?> showFilePickerDialog({
  required BuildContext context,
  List<String>? allowedExtensions,
  int? maxFileSize,
  int? maxFiles,
  bool allowMultiple = true,
  String? knowledgeBaseId,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => FilePickerDialog(
      allowedExtensions: allowedExtensions,
      maxFileSize: maxFileSize,
      maxFiles: maxFiles,
      allowMultiple: allowMultiple,
      knowledgeBaseId: knowledgeBaseId,
    ),
  );
} 