// Control for how will be writted
// the messages of the errors
// or info logs
enum LogState {
  // show debug information like stacktrace or the the time where
  // the error was throwed
  debug,
  // show just a basic messages of the action
  production,
  // no shows nothing
  noState,
}
