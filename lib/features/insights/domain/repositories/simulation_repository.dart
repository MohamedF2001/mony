import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/simulation.dart';

abstract class SimulationRepository {
  Future<Either<Failure, Simulation>> createSimulation(Simulation simulation);
  Future<Either<Failure, List<Simulation>>> getMySimulations();
  Future<Either<Failure, void>> deleteSimulation(String id);
}
