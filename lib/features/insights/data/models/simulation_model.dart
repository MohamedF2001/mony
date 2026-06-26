import 'package:hive/hive.dart';
import '../../domain/entities/simulation.dart';

//part 'simulation_model.g.dart';

@HiveType(typeId: 20)
class SimulationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final Map<String, dynamic> parameters;

  @HiveField(3)
  final Map<String, dynamic> results;

  @HiveField(4)
  final String scenarioType;

  @HiveField(5)
  final DateTime createdAt;

  SimulationModel({
    required this.id,
    required this.name,
    required this.parameters,
    required this.results,
    required this.scenarioType,
    required this.createdAt,
  });

  factory SimulationModel.fromEntity(Simulation entity) {
    return SimulationModel(
      id: entity.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: entity.name,
      parameters: {
        'initialAmount': entity.parameters.initialAmount,
        'monthlyContribution': entity.parameters.monthlyContribution,
        'annualReturnRate': entity.parameters.annualReturnRate,
        'durationMonths': entity.parameters.durationMonths,
        'inflationRate': entity.parameters.inflationRate,
      },
      results: {
        'totalInvested': entity.results.totalInvested,
        'finalBalance': entity.results.finalBalance,
        'totalInterest': entity.results.totalInterest,
        'yearlyBreakdown': entity.results.yearlyBreakdown.map((e) => {
          'year': e.year,
          'balance': e.balance,
          'interest': e.interest,
        }).toList(),
      },
      scenarioType: entity.scenarioType.name,
      createdAt: entity.createdAt ?? DateTime.now(),
    );
  }

  Simulation toEntity() {
    return Simulation(
      id: id,
      name: name,
      parameters: SimulationParameters(
        initialAmount: (parameters['initialAmount'] as num).toDouble(),
        monthlyContribution: (parameters['monthlyContribution'] as num).toDouble(),
        annualReturnRate: (parameters['annualReturnRate'] as num).toDouble(),
        durationMonths: (parameters['durationMonths'] as num).toInt(),
        inflationRate: (parameters['inflationRate'] as num).toDouble(),
      ),
      results: SimulationResults(
        totalInvested: (results['totalInvested'] as num).toDouble(),
        finalBalance: (results['finalBalance'] as num).toDouble(),
        totalInterest: (results['totalInterest'] as num).toDouble(),
        yearlyBreakdown: (results['yearlyBreakdown'] as List).map((e) => YearlyBreakdown(
          year: e['year'] as int,
          balance: (e['balance'] as num).toDouble(),
          interest: (e['interest'] as num).toDouble(),
        )).toList(),
      ),
      scenarioType: ScenarioType.values.firstWhere((e) => e.name == scenarioType),
      createdAt: createdAt,
    );
  }
}
