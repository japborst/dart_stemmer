# stemmer

This package implements [PorterStemmer](https://tartarus.org/martin/PorterStemmer/) in Dart.
It is a port of the exceptional [Python NLTK](https://github.com/nltk/nltk) library.

## Example

```dart
import 'stemmer/PorterStemmer.dart';

stemmer = PorterStemmer();
stemmer.stem('caresses');
// caress
```
