// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutAdapter extends TypeAdapter<Workout> {
  @override
  final int typeId = 2;

  @override
  Workout read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Workout(
      fields[0] as String,
      (fields[1] as List).cast<Exercise>(),
    );
  }

  @override
  void write(BinaryWriter writer, Workout obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj._name)
      ..writeByte(1)
      ..write(obj._exercises);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
