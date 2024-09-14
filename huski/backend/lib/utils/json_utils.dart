import 'package:meta/meta.dart';

typedef Json = Map<String, Object?>;

mixin SerializableTo<T> {
  @mustCallSuper
  T toJson();
}

mixin Serializable implements SerializableTo<Json> {}

extension SerializableJsonList on Iterable<Serializable> {
  List<Json> toJsonList() => map((entry) => entry.toJson()).toList();
}