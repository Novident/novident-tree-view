extension NonZero on int {
  int get oneIfZero => this <= 0 ? 1 : this;
  int get zeroIfNegative => this < 0 ? 0 : this;
}
