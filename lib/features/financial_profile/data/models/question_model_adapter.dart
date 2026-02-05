import 'package:hive/hive.dart';
import 'question_model.dart';

class QuestionModelAdapter extends TypeAdapter<QuestionModel> {
  @override
  final int typeId = 10;

  @override
  QuestionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };

    final choicesList = (fields[3] as List).cast<AnswerChoiceModel>();

    return QuestionModel(
      id: fields[0] as String,
      text: fields[1] as String,
      typeIndex: fields[2] as int,
      choices: choicesList,
      freeTextPrompt: fields[4] as String?,
      isRequired: fields[5] as bool,
      weight: fields[6] as double,
      order: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, QuestionModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.typeIndex)
      ..writeByte(3)
      ..write(obj.choices)
      ..writeByte(4)
      ..write(obj.freeTextPrompt)
      ..writeByte(5)
      ..write(obj.isRequired)
      ..writeByte(6)
      ..write(obj.weight)
      ..writeByte(7)
      ..write(obj.order);
  }
}

class AnswerChoiceModelAdapter extends TypeAdapter<AnswerChoiceModel> {
  @override
  final int typeId = 11;

  @override
  AnswerChoiceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };

    return AnswerChoiceModel(
      id: fields[0] as String,
      text: fields[1] as String,
      scoresMap: Map<int, int>.from(fields[2] as Map),
    );
  }

  @override
  void write(BinaryWriter writer, AnswerChoiceModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.scoresMap);
  }
}
