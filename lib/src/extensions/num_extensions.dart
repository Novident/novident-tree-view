extension NullableNegatives on num {
  num? get nullableNegative => this < 0.0 ? null : this;
}
