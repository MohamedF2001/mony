import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/simulation_repository.dart';

class DeleteSimulation {
  final SimulationRepository repository;

  DeleteSimulation(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    return await repository.deleteSimulation(id);
  }
}
