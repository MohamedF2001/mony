import 'package:hive/hive.dart';
import 'budget_model.dart';

class BudgetModelAdapter extends TypeAdapter<BudgetModel> {
  @override
  final int typeId = 3; // reste identique à l’ancienne version

  @override
  BudgetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };

    return BudgetModel(
      id: fields[0] as String,
      category: fields[1] as String,
      amount: fields[2] as double,
      period: fields[3] as int,
      startDate: fields[4] as DateTime,
      endDate: fields[5] as DateTime?,
      isActive: fields[6] as bool,
      createdAt: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BudgetModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.category)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.period)
      ..writeByte(4)
      ..write(obj.startDate)
      ..writeByte(5)
      ..write(obj.endDate)
      ..writeByte(6)
      ..write(obj.isActive)
      ..writeByte(7)
      ..write(obj.createdAt);
  }
}
