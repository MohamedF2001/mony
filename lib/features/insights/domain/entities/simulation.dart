import 'package:equatable/equatable.dart';

enum ScenarioType { optimistic, realistic, prudent }

class Simulation extends Equatable {
  final String? id;
  final String name;
  final SimulationParameters parameters;
  final SimulationResults results;
  final ScenarioType scenarioType;
  final DateTime? createdAt;

  const Simulation({
    this.id,
    required this.name,
    required this.parameters,
    required this.results,
    this.scenarioType = ScenarioType.realistic,
    this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, name, parameters, results, scenarioType, createdAt];
}

class SimulationParameters extends Equatable {
  final double initialAmount;
  final double monthlyContribution;
  final double annualReturnRate;
  final int durationMonths;
  final double inflationRate;

  const SimulationParameters({
    this.initialAmount = 0,
    this.monthlyContribution = 0,
    this.annualReturnRate = 0,
    this.durationMonths = 12,
    this.inflationRate = 0,
  });

  @override
  List<Object?> get props => [
    initialAmount,
    monthlyContribution,
    annualReturnRate,
    durationMonths,
    inflationRate,
  ];
}

class SimulationResults extends Equatable {
  final double totalInvested;
  final double finalBalance;
  final double totalInterest;
  final List<YearlyBreakdown> yearlyBreakdown;

  const SimulationResults({
    required this.totalInvested,
    required this.finalBalance,
    required this.totalInterest,
    required this.yearlyBreakdown,
  });

  @override
  List<Object?> get props =>
      [totalInvested, finalBalance, totalInterest, yearlyBreakdown];
}

class YearlyBreakdown extends Equatable {
  final int year;
  final double balance;
  final double interest;

  // ── Champs cumulatifs ajoutés pour le tableau de projection ──
  // cumInvested  = capital versé au total jusqu'à cette période
  // cumInterest  = intérêts cumulés jusqu'à cette période
  //
  // Si ton provider ne les calcule pas encore, ils sont dérivés
  // automatiquement via le getter computed (voir ci-dessous).
  final double? cumInvested;
  final double? cumInterest;

  const YearlyBreakdown({
    required this.year,
    required this.balance,
    required this.interest,
    this.cumInvested,
    this.cumInterest,
  });

  /// Intérêts cumulés réels si fournis, sinon on approche via balance - cumInvested.
  double get totalInterestDisplay =>
      cumInterest ?? (cumInvested != null ? balance - cumInvested! : interest);

  /// Capital investi cumulé réel si fourni, sinon on utilise balance - interest (approximation).
  double get totalInvestedDisplay => cumInvested ?? (balance - interest);

  @override
  List<Object?> get props =>
      [year, balance, interest, cumInvested, cumInterest];
}