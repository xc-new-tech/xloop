import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/faq_entity.dart';
import '../repositories/faq_repository.dart';

class CreateFaqUseCase implements UseCase<FaqEntity, FaqEntity> {
  final FaqRepository repository;

  CreateFaqUseCase(this.repository);

  @override
  Future<Either<Failure, FaqEntity>> call(FaqEntity params) async {
    return await repository.createFaq(params);
  }
} 