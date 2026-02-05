import 'package:hive/hive.dart';
import 'answer_model.dart';

class AnswerModelAdapter extends TypeAdapter<AnswerModel> {
  @override
  final int typeId = 12;

  @override
  AnswerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };

    return AnswerModel(
      questionId: fields[0] as String,
      selectedChoiceId: fields[1] as String?,
      freeText: fields[2] as String?,
      answeredAt: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AnswerModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.questionId)
      ..writeByte(1)
      ..write(obj.selectedChoiceId)
      ..writeByte(2)
      ..write(obj.freeText)
      ..writeByte(3)
      ..write(obj.answeredAt);
  }
}
