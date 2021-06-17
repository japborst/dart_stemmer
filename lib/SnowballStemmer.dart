// SPDX-License-Identifier: Apache-2.0

/// Snowball Stemmer
///
/// The is a port of the Snowball implementation contained in NLTK
///
/// The algorithm for English is documented here:
///    Porter, M. \"An algorithm for suffix stripping.\"
///    Program 14.3 (1980): 130-137.
///
/// The algorithms have been developed by Martin Porter.
/// These stemmers are called Snowball, because Porter created
/// a programming language with this name for creating
/// new stemming algorithms. There is more information available
/// at http://snowball.tartarus.org/
///
/// A detailed description of the English stemming algorithm can be found under
/// http://snowball.tartarus.org/algorithms/english/stemmer.html

class SnowballStemmer {
  final _vowels = 'aeiouy';
  final _doubleConsonants = [
    'bb',
    'dd',
    'ff',
    'gg',
    'mm',
    'nn',
    'pp',
    'rr',
    'tt'
  ];
  final _liEnding = 'cdeghkmnrt';
  final _step0Suffixes = ["'s'", "'s", "'"];
  final _step1aSuffixes = ['sses', 'ied', 'ies', 'us', 'ss', 's'];
  final _step1bSuffixes = ['eedly', 'ingly', 'edly', 'eed', 'ing', 'ed'];
  final _step2Suffixes = [
    'ization',
    'ational',
    'fulness',
    'ousness',
    'iveness',
    'tional',
    'biliti',
    'lessli',
    'entli',
    'ation',
    'alism',
    'aliti',
    'ousli',
    'iviti',
    'fulli',
    'enci',
    'anci',
    'abli',
    'izer',
    'ator',
    'alli',
    'bli',
    'ogi',
    'li',
  ];
  final _step3Suffixes = [
    'ational',
    'tional',
    'alize',
    'icate',
    'iciti',
    'ative',
    'ical',
    'ness',
    'ful',
  ];
  final _step4Suffixes = [
    'ement',
    'ance',
    'ence',
    'able',
    'ible',
    'ment',
    'ant',
    'ent',
    'ism',
    'ate',
    'iti',
    'ous',
    'ive',
    'ize',
    'ion',
    'al',
    'er',
    'ic',
  ];

  final Map<String, String> _specialWords = {
    'skis': 'ski',
    'skies': 'sky',
    'dying': 'die',
    'lying': 'lie',
    'tying': 'tie',
    'idly': 'idl',
    'gently': 'gentl',
    'ugly': 'ugli',
    'early': 'earli',
    'only': 'onli',
    'singly': 'singl',
    'sky': 'sky',
    'news': 'news',
    'howe': 'howe',
    'atlas': 'atlas',
    'cosmos': 'cosmos',
    'bias': 'bias',
    'andes': 'andes',
    'inning': 'inning',
    'innings': 'inning',
    'outing': 'outing',
    'outings': 'outing',
    'canning': 'canning',
    'cannings': 'canning',
    'herring': 'herring',
    'herrings': 'herring',
    'earring': 'earring',
    'earrings': 'earring',
    'proceed': 'proceed',
    'proceeds': 'proceed',
    'proceeded': 'proceed',
    'proceeding': 'proceed',
    'exceed': 'exceed',
    'exceeds': 'exceed',
    'exceeded': 'exceed',
    'exceeding': 'exceed',
    'succeed': 'succeed',
    'succeeds': 'succeed',
    'succeeded': 'succeed',
    'succeeding': 'succeed',
  };

  String _r1 = '';
  String _r2 = '';

  String _word = '';

  String stem(String origWord, {toLowerCase: true}) {
    _word = toLowerCase ? origWord.toLowerCase() : origWord;

    // TODO(jeffbailey): Check stopwords
    if (_word.length <= 2) return _word;

    if (_specialWords.containsKey(_word)) return _specialWords[_word]!;

    // Map the different apostrophe characters to a single consistent one
    _word = _word
        .replaceAll('\u2019', '\x27')
        .replaceAll('\u2018', '\x27')
        .replaceAll('\u201B', '\x27');

    if (_word.startsWith('\x27')) _word = _word.substring(1);

    if (_word.startsWith('y')) _word = 'Y' + _word.substring(1);

    // Starts on second letter.
    for (var i = 1; i < _word.length; i++) {
      if (_vowels.contains(_word[i - 1]) && _word[i] == 'y') {
        _word = _word.substring(0, i) + 'Y' + _word.substring(i + 1);
      }
    }

    if (_word.startsWith('gener') ||
        _word.startsWith('commun') ||
        _word.startsWith('arsen')) {
      if (_word.startsWith('gener') || _word.startsWith('arsen')) {
        _r1 = _word.substring(5);
      } else {
        _r1 = _word.substring(6);
      }

      // Starts on second letter.
      for (var i = 1; i < _r1.length; i++) {
        if (!_vowels.contains(_r1[i]) && _vowels.contains(_r1[i - 1])) {
          _r2 = _r1.substring(i + 1);
          break;
        }
      }
    } else {
      _r1r2Standard();
    }

    _step0();
    _step1a();
    _step1b();
    _step1c();
    _step2();
    _step3();
    _step4();
    _step5();

    _word = _word.replaceAll('Y', 'y');

    return _word;
  }

  // Return the standard interpretations of the string regions R1 and R2.
  //
  // R1 is the region after the first non-vowel following a vowel,
  // or is the null region at the end of the word if there is no
  // such non-vowel.
  //
  // R2 is the region after the first non-vowel following a vowel
  // in R1, or is the null region at the end of the word if there
  // is no such non-vowel.
  //
  // A detailed description of how to define R1 and R2
  // can be found at http://snowball.tartarus.org/texts/r1r2.html
  void _r1r2Standard() {
    _r1 = '';
    _r2 = '';

    // Starts on second letter.
    for (var i = 1; i < _word.length; i++) {
      if (!_vowels.contains(_word[i]) && _vowels.contains(_word[i - 1])) {
        _r1 = _word.substring(i + 1);
        break;
      }
    }

    // Starts on second letter.
    for (var i = 1; i < _r1.length; i++) {
      if (!_vowels.contains(_r1[i]) && _vowels.contains(_r1[i - 1])) {
        _r2 = _r1.substring(i + 1);
        break;
      }
    }
  }

  void _step0() {
    for (var suffix in _step0Suffixes) {
      if (_word.endsWith(suffix)) {
        _word = _stripEnd(_word, suffix.length);
        _r1 = _stripEnd(_r1, suffix.length);
        _r2 = _stripEnd(_r2, suffix.length);
      }
    }
  }

  void _step1a() {
    for (var suffix in _step1aSuffixes) {
      if (_word.endsWith(suffix)) {
        switch (suffix) {
          case 'sses':
            _word = _stripEnd(_word, 2);
            _r1 = _stripEnd(_r1, 2);
            _r2 = _stripEnd(_r2, 2);
            break;
          case 'ied':
          case 'ies':
            if (_word.substring(0, _word.length - suffix.length).length > 1) {
              _word = _stripEnd(_word, 2);
              _r1 = _stripEnd(_r1, 2);
              _r2 = _stripEnd(_r2, 2);
            } else {
              _word = _stripEnd(_word, 1);
              _r1 = _stripEnd(_r1, 1);
              _r2 = _stripEnd(_r2, 1);
            }
            break;
          case 's':
            var step1a_vowel_found = false;
            for (var i = 0; i < _word.length - 2; i++) {
              if (_vowels.contains(_word[i])) {
                step1a_vowel_found = true;
              }
            }
            if (step1a_vowel_found) {
              _word = _stripEnd(_word, 1);
              _r1 = _stripEnd(_r1, 1);
              _r2 = _stripEnd(_r2, 1);
            }
            break;
        }
        break;
      }
    }
  }

  void _step1b() {
    for (var suffix in _step1bSuffixes) {
      if (_word.endsWith(suffix)) {
        // Interestingly, "eedly" isn't in the test data.
        // According to the Internets, there are only 9 words
        // in English that end in "eedly"
        if (suffix == 'eed' || suffix == 'eedly') {
          if (_r1.endsWith(suffix)) {
            _word = _suffixReplace(_word, suffix, 'ee');
            _r1 = _safeSuffixReplace(_r1, suffix, 'ee');
            _r2 = _safeSuffixReplace(_r2, suffix, 'ee');
          }
          break;
        } else {
          var step1b_vowel_found = false;
          for (var i = 0; i < _word.length - suffix.length; i++) {
            if (_vowels.contains(_word[i])) {
              step1b_vowel_found = true;
              break;
            }
          }

          if (step1b_vowel_found) {
            _word = _stripEnd(_word, suffix.length);
            _r1 = _stripEnd(_r1, suffix.length);
            _r2 = _stripEnd(_r2, suffix.length);

            if (_word.endsWith('at') ||
                _word.endsWith('bl') ||
                _word.endsWith('iz')) {
              _word = _word + 'e';
              _r1 = _r1 + 'e';

              if (_word.length > 5 || _r1.length >= 3) {
                _r2 = _r2 + 'e';
              }
              return;
            }
            for (var dbl in _doubleConsonants) {
              if (_word.endsWith(dbl)) {
                _word = _stripEnd(_word, 1);
                _r1 = _stripEnd(_r1, 1);
                _r2 = _stripEnd(_r2, 1);
                return;
              }
            }

            if ((_r1 == '' &&
                    _word.length >= 3 &&
                    !_vowels.contains(_word[_word.length - 1]) &&
                    !'wxY'.contains(_word[_word.length - 1]) &&
                    _vowels.contains(_word[_word.length - 2]) &&
                    !_vowels.contains(_word[_word.length - 3])) ||
                (_r1 == '' &&
                    _word.length == 2 &&
                    _vowels.contains(_word[0]) &&
                    !_vowels.contains(_word[1]))) {
              _word = _word + 'e';
              if (_r1.isNotEmpty) _r1 = _r1 + 'e';
              if (_r2.isNotEmpty) _r2 = _r2 + 'e';
            }
          }
        }
        return;
      }
    }
  }

  void _step1c() {
    if (_word.length > 2 &&
        'yY'.contains(_word[_word.length - 1]) &&
        !_vowels.contains(_word[_word.length - 2])) {
      _word = _suffixReplaceLen(_word, 1, 'i');
      _r1 = _safeSuffixReplaceLen(_r1, 1, 'i');
      _r2 = _safeSuffixReplaceLen(_r2, 1, 'i');
    }
  }

  void _step2() {
    for (var suffix in _step2Suffixes) {
      if (_word.endsWith(suffix)) {
        if (_r1.endsWith(suffix)) {
          switch (suffix) {
            case 'tional':
              _word = _stripEnd(_word, 2);
              _r1 = _stripEnd(_r1, 2);
              _r2 = _stripEnd(_r2, 2);
              break;
            case 'enci':
            case 'anci':
            case 'abli':
              _word = _stripEnd(_word, 1) + 'e';

              if (_r1.isNotEmpty) {
                _r1 = _stripEnd(_r1, 1) + 'e';
              } else {
                _r1 = '';
              }

              if (_r2.isNotEmpty) {
                _r2 = _stripEnd(_r2, 1) + 'e';
              } else {
                _r2 = '';
              }
              break;

            case 'entli':
              _word = _stripEnd(_word, 2);
              _r1 = _stripEnd(_r1, 2);
              _r2 = _stripEnd(_r2, 2);
              break;

            case 'izer':
            case 'ization':
              _word = _suffixReplace(_word, suffix, 'ize');
              _r1 = _safeSuffixReplace(_r1, suffix, 'ize');
              _r2 = _safeSuffixReplace(_r2, suffix, 'ize');
              break;
            case 'ational':
            case 'ation':
            case 'ator':
              _word = _suffixReplace(_word, suffix, 'ate');
              _r1 = _safeSuffixReplace(_r1, suffix, 'ate');
              _r2 = _safeSuffixReplace(_r2, suffix, 'ate', 'e');
              break;
            case 'alism':
            case 'aliti':
            case 'alli':
              _word = _suffixReplace(_word, suffix, 'al');
              _r1 = _safeSuffixReplace(_r1, suffix, 'al');
              _r2 = _safeSuffixReplace(_r2, suffix, 'al');
              break;
            case 'fulness':
              _word = _stripEnd(_word, 4);
              _r1 = _stripEnd(_r1, 4);
              _r2 = _stripEnd(_r2, 4);
              break;
            case 'ousli':
            case 'ousness':
              _word = _suffixReplace(_word, suffix, 'ous');
              _r1 = _safeSuffixReplace(_r1, suffix, 'ous');
              _r2 = _safeSuffixReplace(_r2, suffix, 'ous');
              break;
            case 'iveness':
            case 'iviti':
              _word = _suffixReplace(_word, suffix, 'ive');
              _r1 = _safeSuffixReplace(_r1, suffix, 'ive');
              _r2 = _safeSuffixReplace(_r2, suffix, 'ive', 'e');
              break;
            case 'biliti':
            case 'bli':
              _word = _suffixReplace(_word, suffix, 'ble');
              _r1 = _safeSuffixReplace(_r1, suffix, 'ble');
              _r2 = _safeSuffixReplace(_r2, suffix, 'ble');
              break;
            case 'ogi':
              if (_word[_word.length - 4] == 'l') {
                _word = _stripEnd(_word, 1);
                _r1 = _stripEnd(_r1, 1);
                _r2 = _stripEnd(_r2, 1);
              }
              break;
            case 'fulli':
            case 'lessli':
              _word = _stripEnd(_word, 2);
              _r1 = _stripEnd(_r1, 2);
              _r2 = _stripEnd(_r2, 2);
              break;
            case 'li':
              if (_liEnding.contains(_word[_word.length - 3])) {
                _word = _stripEnd(_word, 2);
                _r1 = _stripEnd(_r1, 2);
                _r2 = _stripEnd(_r2, 2);
              }
              break;
          }
        }
        return;
      }
    }
  }

  void _step3() {
    for (var suffix in _step3Suffixes) {
      if (_word.endsWith(suffix)) {
        if (_r1.endsWith(suffix)) {
          switch (suffix) {
            case 'tional':
              _word = _stripEnd(_word, 2);
              _r1 = _stripEnd(_r1, 2);
              _r2 = _stripEnd(_r2, 2);
              break;
            case 'ational':
              _word = _suffixReplace(_word, suffix, 'ate');
              _r1 = _safeSuffixReplace(_r1, suffix, 'ate');
              _r2 = _safeSuffixReplace(_r2, suffix, 'ate');
              break;
            case 'alize':
              _word = _stripEnd(_word, 3);
              _r1 = _stripEnd(_r1, 3);
              _r2 = _stripEnd(_r2, 3);
              break;
            case 'icate':
            case 'iciti':
            case 'ical':
              _word = _suffixReplace(_word, suffix, 'ic');
              _r1 = _safeSuffixReplace(_r1, suffix, 'ic');
              _r2 = _safeSuffixReplace(_r2, suffix, 'ic');
              break;
            case 'ful':
            case 'ness':
              _word = _stripEnd(_word, suffix.length);
              _r1 = _stripEnd(_r1, suffix.length);
              _r2 = _stripEnd(_r2, suffix.length);
              break;
            case 'ative':
              if (_r2.endsWith(suffix)) {
                _word = _stripEnd(_word, suffix.length);
                _r1 = _stripEnd(_r1, suffix.length);
                _r2 = _stripEnd(_r2, suffix.length);
              }
          }
        }
      }
    }
  }

  void _step4() {
    for (var suffix in _step4Suffixes) {
      if (_word.endsWith(suffix)) {
        if (_r2.endsWith(suffix)) {
          if (suffix == 'ion') {
            if ('st'.contains(_word[_word.length - 4])) {
              _word = _stripEnd(_word, 3);
              _r1 = _stripEnd(_r1, 3);
              _r2 = _stripEnd(_r2, 3);
            }
          } else {
            _word = _stripEnd(_word, suffix.length);
            _r1 = _stripEnd(_r1, suffix.length);
            _r2 = _stripEnd(_r2, suffix.length);
          }
        }
        break;
      }
    }
  }

  void _step5() {
    if (_r2.endsWith('l') && _word[_word.length - 2] == 'l') {
      _word = _stripEnd(_word, 1);
      return;
    }
    if (_r2.endsWith('e')) {
      _word = _stripEnd(_word, 1);
      return;
    }
    if (_r1.endsWith('e')) {
      if (_word.length >= 4 &&
          (_vowels.contains(_word[_word.length - 2]) ||
              'wxY'.contains(_word[_word.length - 2]) ||
              !_vowels.contains(_word[_word.length - 3]) ||
              _vowels.contains(_word[_word.length - 4]))) {
        _word = _stripEnd(_word, 1);
      }
    }
  }

  String _safeSuffixReplace(String word, String oldSuffix, String newSuffix,
          [String failureSuffix = '']) =>
      word.length >= oldSuffix.length
          ? _suffixReplace(word, oldSuffix, newSuffix)
          : failureSuffix;

  String _safeSuffixReplaceLen(
          String word, int oldSuffixLength, String newSuffix) =>
      word.length >= oldSuffixLength
          ? _suffixReplaceLen(word, oldSuffixLength, newSuffix)
          : '';

  String _suffixReplace(String word, String oldSuffix, String newSuffix) =>
      _suffixReplaceLen(word, oldSuffix.length, newSuffix);

  String _suffixReplaceLen(
          String word, int oldSuffixLength, String newSuffix) =>
      word.substring(0, word.length - oldSuffixLength) + newSuffix;

  String _stripEnd(String word, int length) =>
      word.length > length ? word.substring(0, word.length - length) : '';
}
