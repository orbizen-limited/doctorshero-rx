// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cached_credentials.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CachedCredentialsAdapter extends TypeAdapter<CachedCredentials> {
  @override
  final int typeId = 4;

  @override
  CachedCredentials read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CachedCredentials(
      email: fields[0] as String,
      passwordHash: fields[1] as String,
      token: fields[2] as String?,
      userData: (fields[3] as Map?)?.cast<String, dynamic>(),
      lastOnlineLogin: fields[4] as DateTime,
      lastOfflineLogin: fields[5] as DateTime,
      offlineLoginCount: fields[6] as int,
      biometricEnabled: fields[7] as bool,
      createdAt: fields[8] as DateTime,
      updatedAt: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CachedCredentials obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.passwordHash)
      ..writeByte(2)
      ..write(obj.token)
      ..writeByte(3)
      ..write(obj.userData)
      ..writeByte(4)
      ..write(obj.lastOnlineLogin)
      ..writeByte(5)
      ..write(obj.lastOfflineLogin)
      ..writeByte(6)
      ..write(obj.offlineLoginCount)
      ..writeByte(7)
      ..write(obj.biometricEnabled)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CachedCredentialsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
