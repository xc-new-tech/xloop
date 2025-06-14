import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/presentation/widgets/base_page.dart';
import '../../domain/entities/faq_entity.dart';
import '../bloc/faq_bloc.dart';
import '../bloc/faq_event.dart';
import '../bloc/faq_state.dart';
import '../widgets/faq_form_widget.dart';

/// FAQ创建/编辑页面
class FaqFormPage extends StatefulWidget {
  final String? faqId; // null表示创建新FAQ，否则为编辑
  final String? initialKnowledgeBaseId;

  const FaqFormPage({
    super.key,
    this.faqId,
    this.initialKnowledgeBaseId,
  });

  @override
  State<FaqFormPage> createState() => _FaqFormPageState();
}

class _FaqFormPageState extends State<FaqFormPage> {
  late FaqBloc _faqBloc;
  bool get isEditing => widget.faqId != null;

  @override
  void initState() {
    super.initState();
    _faqBloc = context.read<FaqBloc>();
    
    if (isEditing) {
      _faqBloc.add(GetFaqByIdEvent(id: widget.faqId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FaqBloc, FaqState>(
      listener: (context, state) {
        if (state.hasError && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return BasePage(
          title: isEditing ? '编辑FAQ' : '创建FAQ',
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(FaqState state) {
    if (isEditing) {
      if (state.isLoading && state.currentFaq == null) {
        return const BaseLoadingPage();
      }

      if (state.hasError && state.currentFaq == null) {
        return BaseErrorPage(
          title: '加载失败',
          subtitle: state.errorMessage ?? '无法加载FAQ信息',
          actionText: '重试',
          onAction: () => _faqBloc.add(GetFaqByIdEvent(id: widget.faqId!)),
        );
      }

      if (state.currentFaq == null) {
        return const BaseEmptyPage(
          title: 'FAQ不存在',
          subtitle: '请检查FAQ ID是否正确',
          icon: Icons.quiz_outlined,
        );
      }
    }

    return FaqFormWidget(
      initialFaq: state.currentFaq,
      initialKnowledgeBaseId: widget.initialKnowledgeBaseId,
      onSubmit: (faqData) => _submitFaq(faqData),
      onCancel: () => context.pop(),
      isSubmitting: state.isSubmitting,
    );
  }

  void _submitFaq(Map<String, dynamic> faqData) {
    // 将Map转换为FaqEntity
    final faq = FaqEntity(
      metadata: {},
      id: isEditing ? widget.faqId! : '',
      question: faqData['question'] as String,
      answer: faqData['answer'] as String,
      category: faqData['category'] as String? ?? '通用',
      tags: (faqData['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      knowledgeBaseId: faqData['knowledgeBaseId'] as String?,
      status: faqData['status'] as FaqStatus? ?? FaqStatus.draft,
      isPublic: faqData['isPublic'] as bool? ?? false,
      priority: FaqPriority.values[faqData['priority'] as int? ?? 0],
      viewCount: 0,
      likeCount: 0,
      dislikeCount: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: '', // 会在服务端设置
      updatedBy: '', // 会在服务端设置
    );

    if (isEditing) {
      _faqBloc.add(UpdateFaqEvent(faq: faq));
    } else {
      _faqBloc.add(CreateFaqEvent(faq: faq));
    }

    // 监听提交结果
    _faqBloc.stream.listen((state) {
      if (!state.isSubmitting && !state.hasError) {
        // 提交成功，返回上一页
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEditing ? 'FAQ更新成功' : 'FAQ创建成功'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        }
      }
    });
  }
} 