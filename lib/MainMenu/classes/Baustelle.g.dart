// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Baustelle.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BaustelleAdapter extends TypeAdapter<Baustelle> {
  @override
  final int typeId = 0;

  @override
  Baustelle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Baustelle(
      fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Baustelle obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BaustelleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
