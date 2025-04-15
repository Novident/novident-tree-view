import 'package:novident_nodes/novident_nodes.dart';

extension NodeCasting on Node {
  NodeContainer castToContainer() => this as NodeContainer;
}

extension CastObject on Object {
  T cast<T>() => this as T;
  T? castOrNull<T>() => this is T ? this as T : null;
}

extension CastDynamic on dynamic {
  T cast<T>() => this as T;
  T? castOrNull<T>() => this is T ? this as T : null;
}
