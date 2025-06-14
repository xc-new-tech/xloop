import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/faq_entity.dart';

abstract class FaqRepository {
  /// 获取FAQ列表
  Future<Either<Failure, List<FaqEntity>>> getFaqs({
    String? search,
    String? category,
    FaqStatus? status,
    String? knowledgeBaseId,
    bool? isPublic,
    FaqSort? sort,
    List<String>? tags,
    int page = 1,
    int limit = 20,
  });

  /// 搜索FAQ
  Future<Either<Failure, List<FaqEntity>>> searchFaqs({
    required FaqFilter filter,
    required FaqSort sort,
    int page = 1,
    int limit = 20,
  });

  /// 获取FAQ详情
  Future<Either<Failure, FaqEntity>> getFaqById(String id);

  /// 创建FAQ
  Future<Either<Failure, FaqEntity>> createFaq(FaqEntity faq);

  /// 更新FAQ
  Future<Either<Failure, FaqEntity>> updateFaq(FaqEntity faq);

  /// 删除FAQ
  Future<Either<Failure, void>> deleteFaq(String id);

  /// 批量删除FAQ
  Future<Either<Failure, void>> bulkDeleteFaqs(List<String> ids);

  /// 获取FAQ分类
  Future<Either<Failure, List<FaqCategory>>> getCategories();

  /// 获取热门FAQ
  Future<Either<Failure, List<FaqEntity>>> getPopularFaqs({
    int limit = 10,
  });

  /// 点赞FAQ
  Future<Either<Failure, FaqEntity>> likeFaq(String id);

  /// 点踩FAQ
  Future<Either<Failure, FaqEntity>> dislikeFaq(String id);

  /// 切换FAQ状态
  Future<Either<Failure, FaqEntity>> toggleFaqStatus(String id);
} 