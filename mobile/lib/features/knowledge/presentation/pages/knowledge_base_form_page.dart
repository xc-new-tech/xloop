import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../domain/entities/knowledge_base.dart';
import '../bloc/knowledge_base_bloc.dart';

class KnowledgeBaseFormPage extends StatefulWidget {
  final KnowledgeBase? knowledgeBase;
  final bool isEditing;

  const KnowledgeBaseFormPage({
    super.key,
    this.knowledgeBase,
    this.isEditing = false,
  });

  @override
  State<KnowledgeBaseFormPage> createState() => _KnowledgeBaseFormPageState();
}

class _KnowledgeBaseFormPageState extends State<KnowledgeBaseFormPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  late String _selectedType;
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.knowledgeBase?.type.name ?? 'Personal';
    _selectedStatus = widget.knowledgeBase?.status.name ?? 'Active';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? '编辑知识库' : '创建知识库'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: BlocListener<KnowledgeBaseBloc, KnowledgeBaseState>(
        listener: (context, state) {
          if (state is KnowledgeBaseCreated || state is KnowledgeBaseUpdated) {
            Navigator.of(context).pop(true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.isEditing ? '知识库更新成功' : '知识库创建成功'),
                backgroundColor: AppColors.success,
              ),
            );
          } else if (state is KnowledgeBaseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('操作失败: ${state.message}'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: FormBuilder(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 基本信息
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '基本信息',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        
                        // 知识库名称
                        CustomTextField(
                          name: 'name',
                          label: '知识库名称',
                          initialValue: widget.knowledgeBase?.name,
                          validator: FormBuilderValidators.compose([
                            FormBuilderValidators.required(errorText: '请输入知识库名称'),
                            FormBuilderValidators.minLength(2, errorText: '名称至少2个字符'),
                            FormBuilderValidators.maxLength(50, errorText: '名称最多50个字符'),
                          ]),
                        ),
                        const SizedBox(height: 16),
                        
                        // 描述
                        CustomTextField(
                          name: 'description',
                          label: '描述',
                          initialValue: widget.knowledgeBase?.description,
                          maxLines: 3,
                          validator: FormBuilderValidators.maxLength(500, errorText: '描述最多500个字符'),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // 类型和状态
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '设置',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        
                        // 知识库类型
                        FormBuilderDropdown<String>(
                          name: 'type',
                          decoration: const InputDecoration(
                            labelText: '知识库类型',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: _selectedType,
                          items: const [
                            DropdownMenuItem(value: 'Personal', child: Text('个人')),
                            DropdownMenuItem(value: 'Team', child: Text('团队')),
                            DropdownMenuItem(value: 'Public', child: Text('公开')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value ?? 'Personal';
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // 状态
                        FormBuilderDropdown<String>(
                          name: 'status',
                          decoration: const InputDecoration(
                            labelText: '状态',
                            border: OutlineInputBorder(),
                          ),
                          initialValue: _selectedStatus,
                          items: const [
                            DropdownMenuItem(value: 'Active', child: Text('活跃')),
                            DropdownMenuItem(value: 'Archived', child: Text('归档')),
                            DropdownMenuItem(value: 'Disabled', child: Text('禁用')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedStatus = value ?? 'Active';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 提交按钮
                SizedBox(
                  width: double.infinity,
                  child: BlocBuilder<KnowledgeBaseBloc, KnowledgeBaseState>(
                    builder: (context, state) {
                      final isLoading = state is KnowledgeBaseLoading;
                      
                      return CustomButton(
                        text: widget.isEditing ? '更新知识库' : '创建知识库',
                        onPressed: isLoading ? null : _submitForm,
                        isLoading: isLoading,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;
      
      if (widget.isEditing && widget.knowledgeBase != null) {
        // 更新知识库
        context.read<KnowledgeBaseBloc>().add(
          UpdateKnowledgeBaseEvent(
            knowledgeBaseId: widget.knowledgeBase!.id,
            name: formData['name'],
            description: formData['description'] ?? '',
            type: _getKnowledgeBaseType(formData['type']),
            status: _getKnowledgeBaseStatus(formData['status']),
          ),
        );
      } else {
        // 创建知识库
        context.read<KnowledgeBaseBloc>().add(
          CreateKnowledgeBaseEvent(
            name: formData['name'],
            description: formData['description'] ?? '',
            type: _getKnowledgeBaseType(formData['type']),
            status: _getKnowledgeBaseStatus(formData['status']),
          ),
        );
      }
    }
  }

  KnowledgeBaseType _getKnowledgeBaseType(String? type) {
    switch (type) {
      case 'Team':
        return KnowledgeBaseType.team;
      case 'Public':
        return KnowledgeBaseType.public;
      default:
        return KnowledgeBaseType.personal;
    }
  }

  KnowledgeBaseStatus _getKnowledgeBaseStatus(String? status) {
    switch (status) {
      case 'Archived':
        return KnowledgeBaseStatus.archived;
      case 'Disabled':
        return KnowledgeBaseStatus.disabled;
      default:
        return KnowledgeBaseStatus.active;
    }
  }
} 