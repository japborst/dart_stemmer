# stemmer

This package implements a [stemming](https://en.wikipedia.org/wiki/Stemming) algorithm in Dart.
Currently, it only supports [PorterStemmer](https://tartarus.org/martin/PorterStemmer/). It is a
port of the exceptional [Python NLTK](https://github.com/nltk/nltk) library.

## About

This package allows for stemming of words. This process reduces a word to their base form. In many
cases, the word will not even be recognisable. Where, for example, `running` would be stemmed to
`run`, which is still a valid word, yet `agreed` would be stemmed to `agre`.

## Example

```dart
import 'package:stemmer/stemmer.dart';

PorterStemmer stemmer = PorterStemmer();
stemmer.stem('running');
// run
```
