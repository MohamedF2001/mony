import 'package:hive/hive.dart';
import 'profile_model.dart';

class FinancialProfileModelAdapter
    extends TypeAdapter<FinancialProfileModel> {
  @override
  final int typeId = 13;

  @override
  FinancialProfileModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };

    return FinancialProfileModel(
      id: fields[0] as String,
      profileTypeIndex: fields[1] as int,
      traitScoresMap: Map<int, double>.from(fields[2] as Map),
      confidenceScore: fields[3] as double,
      aiFeedback: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, FinancialProfileModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.profileTypeIndex)
      ..writeByte(2)
      ..write(obj.traitScoresMap)
      ..writeByte(3)
      ..write(obj.confidenceScore)
      ..writeByte(4)
      ..write(obj.aiFeedback)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }
}
