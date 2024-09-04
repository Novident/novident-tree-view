import 'package:uuid/v1.dart';
import 'package:uuid/v4.dart';
import 'package:uuid/v5.dart';
import 'package:uuid/v7.dart';

const UuidV4 _generatorV4 = UuidV4();
const UuidV5 _generatorV5 = UuidV5();
const UuidV1 _generatorV1 = UuidV1();
const UuidV7 _generatorV7 = UuidV7();

String generateIdV4() {
  return _generatorV4.generate();
}

String generateIdV1() {
  return _generatorV1.generate();
}

String generateIdV7() {
  return _generatorV7.generate();
}

String generateIdV5(String namespace, String name) {
  return _generatorV5.generate(namespace, name);
}
