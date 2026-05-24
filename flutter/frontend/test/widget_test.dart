import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:travel_planner/main.dart';

void main() {
  test('Seoul palette exposes core brand colours', () {
    expect(SeoulPalette.persimmon, isA<Color>());
    expect(SeoulPalette.hanNavy, isA<Color>());
    expect(SeoulPalette.gold, isA<Color>());
    expect(SeoulPalette.jade, isA<Color>());
  });
}
