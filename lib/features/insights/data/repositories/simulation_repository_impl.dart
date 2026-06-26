import '../../domain/entities/simulation.dart';
import '../../domain/repositories/simulation_repository.dart';
import '../datasources/simulation_remote_datasource.dart';

class SimulationRepositoryImpl implements SimulationRepository {
  final SimulationRemoteDataSource remoteDataSource;

  SimulationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Simulation> createSimulation(Simulation simulation) async {
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
    
    return _mapToEntity(item);
  }

  @override
  Future<List<Simulation>> getMySimulations() async {
    final response = await remoteDataSource.getMySimulations();
    final List list = response['data']['simulations'];
    
    return list.map((item) => _mapToEntity(item)).toList();
  }

  @override
  Future<void> deleteSimulation(String id) async {
    await remoteDataSource.deleteSimulation(id);
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
