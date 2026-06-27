import 'simulation_model.dart';

class SimulationModelAdapter extends TypeAdapter<SimulationModel> {
  @override
  final int typeId = 20;

  @override
  SimulationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };

    return SimulationModel(
      id: fields[0] as String,
      name: fields[1] as String,
      parameters: (fields[2] as Map).cast<String, dynamic>(),
      results: (fields[3] as Map).cast<String, dynamic>(),
      scenarioType: fields[4] as String,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SimulationModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.parameters)
      ..writeByte(3)
      ..write(obj.results)
      ..writeByte(4)
      ..write(obj.scenarioType)
      ..writeByte(5)
      ..write(obj.createdAt);
  }
}
