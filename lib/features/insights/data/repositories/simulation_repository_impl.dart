import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/simulation.dart';
import '../../domain/repositories/simulation_repository.dart';
import '../datasources/simulation_remote_datasource.dart';

class SimulationRepositoryImpl implements SimulationRepository {
  final SimulationRemoteDataSource remoteDataSource;

  SimulationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Simulation>> createSimulation(
      Simulation simulation) async {
    try {
      final data = {
        'name': simulation.name,
        'parameters': {
          'initialAmount': simulation.parameters.initialAmount,
          'monthlyContribution': simulation.parameters.monthlyContribution,
          'annualReturnRate': simulation.parameters.annualReturnRate,
          'durationMonths': simulation.parameters.durationMonths,
          'inflationRate': simulation.parameters.inflationRate,
        },
        'scenarioType': simulation.scenarioType.name,
      };

      final response = await remoteDataSource.createSimulation(data);
      final item = response['data']['simulation'];

      return Right(_mapToEntity(item));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Simulation>>> getMySimulations() async {
    try {
      final response = await remoteDataSource.getMySimulations();
      final List list = response['data']['simulations'];

      return Right(list.map((item) => _mapToEntity(item)).toList());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSimulation(String id) async {
    try {
      await remoteDataSource.deleteSimulation(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Simulation _mapToEntity(Map<String, dynamic> item) {
    return Simulation(
      id: item['_id'],
      name: item['name'],
      parameters: SimulationParameters(
        initialAmount: (item['parameters']['initialAmount'] as num).toDouble(),
        monthlyContribution: (item['parameters']['monthlyContribution'] as num).toDouble(),
        annualReturnRate: (item['parameters']['annualReturnRate'] as num).toDouble(),
        durationMonths: (item['parameters']['durationMonths'] as num).toInt(),
        inflationRate: (item['parameters']['inflationRate'] as num).toDouble(),
      ),
      results: SimulationResults(
        totalInvested: (item['results']['totalInvested'] as num).toDouble(),
        finalBalance: (item['results']['finalBalance'] as num).toDouble(),
        totalInterest: (item['results']['totalInterest'] as num).toDouble(),
        yearlyBreakdown: (item['results']['yearlyBreakdown'] as List).map((e) => YearlyBreakdown(
          year: e['year'] as int,
          balance: (e['balance'] as num).toDouble(),
          interest: (e['interest'] as num).toDouble(),
        )).toList(),
      ),
      scenarioType: ScenarioType.values.firstWhere((e) => e.name == item['scenarioType']),
      createdAt: DateTime.parse(item['createdAt']),
    );
  }
}
