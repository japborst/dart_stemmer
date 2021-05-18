// SPDX-License-Identifier: Apache-2.0

import 'dart:collection';
import 'dart:core';
import 'dart:io';

import 'package:test/test.dart';
import 'package:stemmer/SnowballStemmer.dart';

final testData = LinkedHashMap<String, String>();
final testDataRegExp = RegExp(r'^([^\s]+)\s+([^\s]+)$');

void main() {
  group('SnowballStemmer tests', () {
    test('stemmer_test.txt tests', () {
      var fails = run_tests();
      expect(fails, 0);
    });
  });
}

int run_tests() {
  var fails = 0;
  var stemmer = SnowballStemmer();

  for (var key in testData.keys) {
    var result = stemmer.stem(key);
    if (result == testData[key]) {
    } else {
      print('Original: ${key}, Expected: ${testData[key]}, Got: ${result}');
      fails++;
    }
  }
  return fails;
}

void loadTestData() {
  File data = File('test/snowball_test.txt');
  var lines = data.readAsLinesSync();
  processLines(lines);
  return;
}

void processLines(List<String> lines) {
  for (var line in lines) {
    if (line[0] == '#') continue;
    Iterable<Match> words = testDataRegExp.allMatches(line);
    for (var match in words) {
      testData[match.group(1)!] = match.group(2)!;
    }
  }
}
