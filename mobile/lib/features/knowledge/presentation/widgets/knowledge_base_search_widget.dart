import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// 知识库搜索组件
class KnowledgeBaseSearchWidget extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onSearchSubmitted;
  final String? hintText;
  final bool autofocus;

  const KnowledgeBaseSearchWidget({
    super.key,
    required this.controller,
    this.onSearchChanged,
    this.onSearchSubmitted,
    this.hintText,
    this.autofocus = false,
  });

  @override
  State<KnowledgeBaseSearchWidget> createState() => _KnowledgeBaseSearchWidgetState();
}

class _KnowledgeBaseSearchWidgetState extends State<KnowledgeBaseSearchWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        autofocus: widget.autofocus,
        onChanged: widget.onSearchChanged,
        onSubmitted: widget.onSearchSubmitted,
        decoration: InputDecoration(
          hintText: widget.hintText ?? '搜索知识库...',
          hintStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.textSecondary,
            size: 24,
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () {
                    widget.controller.clear();
                    widget.onSearchChanged?.call('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
      ),
    );
  }
} 