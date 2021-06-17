import "package:test/test.dart";

import '../lib/stemmer.dart';

void main() {
  PorterStemmer stemmer = PorterStemmer();

  test("Can stem", () {
    expect(stemmer.stem('running'), equals('run'));
  });

  test("Stems lowercase by default", () {
    expect(stemmer.stem("Running"), equals("run"));
  });

  test("Stems case-sensitive when set", () {
    expect(stemmer.stem("JumPing", toLowerCase: false), equals("JumP"));
  });

  test("Stems only the last word in a sentence", () {
    String sentence = "Kicking running JumPing";
    expect(sentence.split(" ").map((s) => stemmer.stem(s)).join(" "),
        equals("kick run jump"));
  });

  test("Can correctly stem various plurals", () {
    List<String> plurals = [
      'caresses',
      'flies',
      'dies',
      'mules',
      'denied',
      'died',
      'agreed',
      'owned',
      'humbled',
      'sized',
      'meeting',
      'stating',
      'siezing',
      'itemization',
      'sensational',
      'traditional',
      'reference',
      'colonizer',
      'plotted'
    ];
    expect(
        plurals.map((word) => stemmer.stem(word)).toList(),
        equals([
          'caress',
          'fli',
          'die',
          'mule',
          'deni',
          'die',
          'agre',
          'own',
          'humbl',
          'size',
          'meet',
          'state',
          'siez',
          'item',
          'sensat',
          'tradit',
          'refer',
          'colon',
          'plot'
        ]));
  });
}
