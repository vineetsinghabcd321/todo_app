import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class TaskItem {
  TaskItem({
    required this.id,
    required this.title,
    required this.scheduledDate,
    required this.createdAt,
    this.isCompleted = false,
    this.description = '',
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final DateTime scheduledDate;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final bool isCompleted;

  @HiveField(5)
  final String description;

  TaskItem copyWith({
    String? id,
    String? title,
    DateTime? scheduledDate,
    DateTime? selectedDate,
    DateTime? createdAt,
    bool? isCompleted,
    String? description,
  }) {
    return TaskItem(
      id: id ?? this.id,
      title: title ?? this.title,
      scheduledDate: selectedDate ?? scheduledDate ?? this.scheduledDate,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      description: description ?? this.description,
    );
  }

  /// Alias for `scheduledDate` matching the external/name contract `selectedDate`.
  DateTime get selectedDate => scheduledDate;
}

class TaskItemAdapter extends TypeAdapter<TaskItem> {
  @override
  final int typeId = 0;

  @override
  TaskItem read(BinaryReader reader) {
    final fields = <int, dynamic>{};
    final fieldCount = reader.readByte();
    for (var index = 0; index < fieldCount; index++) {
      fields[reader.readByte()] = reader.read();
    }

    return TaskItem(
      id: fields[0] as String,
      title: fields[1] as String,
      scheduledDate: fields[2] as DateTime,
      createdAt: fields[3] as DateTime,
      isCompleted: fields[4] as bool? ?? false,
      description: fields[5] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, TaskItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.scheduledDate)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.isCompleted);
    writer
      ..writeByte(5)
      ..write(obj.description);
  }
}
