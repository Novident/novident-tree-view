extension NonZero on int {
  int get oneIfZero => this <= 0 ? 1 : this;
}
