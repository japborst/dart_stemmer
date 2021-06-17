# stemmer

This package implements a [stemming](https://en.wikipedia.org/wiki/Stemming) algorithm in Dart.
Currently, it supports [PorterStemmer](https://tartarus.org/martin/PorterStemmer/) and
[SnowballStemmer](https://snowballstem.org/). It is a port of the exceptional
[Python NLTK](https://github.com/nltk/nltk) library.

## About

This package allows for stemming of words. This process reduces a word to their base form. In many
cases, the word will not even be recognisable. Where, for example, `running` would be stemmed to
`run`, which is still a valid word, yet `agreed` would be stemmed to `agre`.

## Example

### PorterStemmer

```dart
import 'package:stemmer/stemmer.dart';

PorterStemmer stemmer = PorterStemmer();
stemmer.stem('running'); // outputs: run
```

### SnowballStemmer

```dart
import 'package:stemmer/stemmer.dart';

SnowballStemmer stemmer = SnowballStemmer();
stemmer.stem('running'); // outputs: run
```

## Case sentitive stemming
The default behaviour is to always return lowercase stemmed words. However, if you wish you can keep 
the original casing.

```dart
import 'package:stemmer/stemmer.dart';

SnowballStemmer stemmer = PorterStemmer();
stemmer.stem('Running'); // outputs: Run
```
