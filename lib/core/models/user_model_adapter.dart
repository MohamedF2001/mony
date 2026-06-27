import '../../features/financial_profile/data/models/profile_model.dart';
import 'user_model.dart';

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 14;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };

    return UserModel(
      id: fields[0] as String,
      name: fields[1] as String,
      financialProfile: fields[2] as FinancialProfileModel?,
      createdAt: fields[3] as DateTime,
      updatedAt: fields[4] as DateTime?,
      isPremium: fields[5] as bool? ?? false,
      premiumUntil: fields[6] as DateTime?,
      subscriptionType: fields[7] as String? ?? 'none',
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.financialProfile)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.isPremium)
      ..writeByte(6)
      ..write(obj.premiumUntil)
      ..writeByte(7)
      ..write(obj.subscriptionType);
  }
}
