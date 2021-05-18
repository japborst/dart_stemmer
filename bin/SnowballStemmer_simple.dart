import 'package:stemmer/SnowballStemmer.dart';
import 'dart:io';

main(List<String> args) {
  var stemmer = SnowballStemmer();
  if (args.length == 0) {
    print('Usage:');
    print('${Platform.script.path} <word to stem>');
    return;
  }
  for (var arg in args) {
    String result = stemmer.stem(arg);
    print(result);
  }
}
