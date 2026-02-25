String convertStringToHex(String input) {
  return input.codeUnits.map((c) => c.toRadixString(16).padLeft(2, '0')).join();
}
