import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/faq_repository.dart';

class DeleteFaqUseCase implements UseCase<void, String> {
  final FaqRepository repository;

  DeleteFaqUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) async {
    return await repository.deleteFaq(params);
  }
} 