/// Class mainly used internally to set a value to NotGiven by its type
class NotGiven {
  /// Simplest constructor ever
  const NotGiven();
}

/// Class used internally as a tuple with 2 items.
class Tuple2<E1, E2> {
  /// First item of the tuple
  E1 item1;

  /// Second item of the tuple
  E2 item2;
  Tuple2(this.item1, this.item2);
}

/// Class used internally as a tuple with 3 items.
class Tuple3<E1, E2, E3> {
  /// First item of the tuple
  E1 item1;

  /// Second item of the tuple
  E2 item2;

  /// Third item of the tuple
  E3 item3;
  Tuple3(this.item1, this.item2, this.item3);
}

/// Class used to send pointers to variables instead of the variable directly so
/// that the called function can update the variable value
class PointerThisPlease<T> {
  /// Value to be pointed to that can be changed by the called method.
  T value;

  /// Simple constructor that sets the value that can be updated by a called
  /// method.
  PointerThisPlease(this.value);
}
