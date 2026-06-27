import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/simulation.dart';
import '../repositories/simulation_repository.dart';

class GetMySimulations {
  final SimulationRepository repository;

  GetMySimulations(this.repository);

  Future<Either<Failure, List<Simulation>>> call() async {
    return await repository.getMySimulations();
  }
}
