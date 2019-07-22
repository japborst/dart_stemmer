import "package:test/test.dart";

import '../lib/stemmer.dart';

void main() {
  test("Can stem", () {
    PorterStemmer stemmer = PorterStemmer();
    expect(stemmer.stem('running'), equals('run'));
  });

  test("Can correctly stem various plurals", () {
    PorterStemmer stemmer = PorterStemmer();
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
