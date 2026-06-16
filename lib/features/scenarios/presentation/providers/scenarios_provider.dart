import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_signal/features/scenarios/data/models/scenario_model.dart';
import 'package:safe_signal/features/scenarios/data/repositories/scenarios_repository.dart';

final scenariosRepositoryProvider = Provider<ScenariosRepository>((ref) {
  return ScenariosRepository();
});

final scenariosStreamProvider = StreamProvider<List<ScenarioModel>>((ref) {
  return ref.watch(scenariosRepositoryProvider).watchScenarios();
});

final scenariosProvider =
    FutureProvider<List<ScenarioModel>>((ref) async {
  return ref.watch(scenariosRepositoryProvider).getScenarios();
});

final scenarioProvider =
    FutureProvider.family<ScenarioModel?, String>((ref, scenarioId) {
  return ref.watch(scenariosRepositoryProvider).getScenario(scenarioId);
});

final defaultScenarioProvider =
    FutureProvider<ScenarioModel?>((ref) async {
  return ref.watch(scenariosRepositoryProvider).getDefaultScenario();
});

final activeScenarioProvider = StateProvider<String?>((ref) => null);
