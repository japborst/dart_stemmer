class PorterStemmer {
  PorterStemmer() {
    _irregularForms.forEach((String key, List<String> value) {
      value.forEach((String val) {
        _pool[val] = key;
      });
    });
  }

  final Map<String, List<String>> _irregularForms = {
    "sky": ["sky", "skies"],
    "die": ["dying"],
    "lie": ["lying"],
    "tie": ["tying"],
    "news": ["news"],
    "inning": ["innings", "inning"],
    "outing": ["outings", "outing"],
    "canning": ["cannings", "canning"],
    "howe": ["howe"],
    "proceed": ["proceed"],
    "exceed": ["exceed"],
    "succeed": ["succeed"],
  };

  Map<String, String> _pool = {};

  final Set<String> _vowels = {'a', 'e', 'i', 'o', 'u'};

  /// Returns true if word[i] is a consonant, false otherwise.
  ///
  /// A consonant is defined in the paper as follows:
  ///
  ///     A consonant in a word is a letter other than A, E, I, O or
  ///     U, and other than Y preceded by a consonant. (The fact that
  ///     the term `consonant' is defined to some extent in terms of
  ///     itself does not make it ambiguous.) So in TOY the consonants
  ///     are T and Y, and in SYZYGY they are S, Z and G. If a letter
  ///     is not a consonant it is a vowel.
  bool _isConsonant(String word, int i) {
    if (_vowels.contains(word[i])) {
      return false;
    }
    if (word[i] == 'y') {
      if (i == 0) {
        return true;
      } else {
        return !_isConsonant(word, i - 1);
      }
    }
    return true;
  }

  /// Returns the 'measure' of [stem], per definition in the paper
  ///
  /// From the paper:
  ///
  /// A consonant will be denoted by c, a vowel by v. A list
  /// ccc... of length greater than 0 will be denoted by C, and a
  /// list vvv... of length greater than 0 will be denoted by V.
  /// Any word, or part of a word, therefore has one of the four
  /// forms:
  ///
  ///     CVCV ... C
  ///     CVCV ... V
  ///     VCVC ... C
  ///     VCVC ... V
  ///
  /// These may all be represented by the single form
  ///
  ///     [C]VCVC ... [V]
  ///
  /// where the square brackets denote arbitrary presence of their
  /// contents. Using (VC){m} to denote VC repeated m times, this
  /// may again be written as
  ///
  ///     [C](VC){m}[V].
  ///
  /// m will be called the \measure\ of any word or word part when
  /// represented in this form. The case m = 0 covers the null
  /// word. Here are some examples:
  ///
  ///     m=0    TR,  EE,  TREE,  Y,  BY.
  ///     m=1    TROUBLE,  OATS,  TREES,  IVY.
  ///     m=2    TROUBLES,  PRIVATE,  OATEN,  ORRERY.
  int _measure(String stem) {
    String cvSequence = '';

    //  Construct a string of 'c's and 'v's representing whether each
    // character in `stem` is a consonant or a vowel.
    // e.g. 'falafel' becomes 'cvcvcvc',
    //  'architecture' becomes 'vcccvcvccvcv'
    for (var i = 0; i < stem.length; i++) {
      if (_isConsonant(stem, i)) {
        cvSequence += 'c';
      } else {
        cvSequence += 'v';
      }
    }

    // Count the number of 'vc' occurences, which is equivalent to
    // the number of 'VC' occurrences in Porter's reduced form in the
    // docstring above, which is in turn equivalent to `m`
    return 'vc'.allMatches(cvSequence).length;
  }

  bool _hasPositiveMeasure(String stem) {
    return _measure(stem) > 0;
  }

  bool _containsVowel(String stem) {
    /// Returns true if stem contains a vowel, else false
    for (var i = 0; i < stem.length; i++) {
      if (!_isConsonant(stem, i)) {
        return true;
      }
    }
    return false;
  }

  /// Implements condition *d from the paper
  ///
  /// Returns true if [word] ends with a double consonant
  bool _endsDoubleConsonant(String word) {
    return word.length >= 2 &&
        word[word.length - 1] == word[word.length - 2] &&
        _isConsonant(word, word.length - 1);
  }

  /// Implements condition *o from the paper
  ///
  /// From the paper:
  ///
  ///    *o  - the stem ends cvc, where the second c is not W, X or Y
  ///          (e.g. -WIL, -HOP).
  bool _endsCvc(String word) {
    return (word.length >= 3 &&
            _isConsonant(word, word.length - 3) &&
            !_isConsonant(word, word.length - 2) &&
            _isConsonant(word, word.length - 1) &&
            !(['w', 'x', 'y'].contains(word[word.length - 1]))) ||
        (word.length == 2 && !_isConsonant(word, 0) && _isConsonant(word, 1));
  }

  /// Replaces [suffix] of [word] with [replacement]
  String _replaceSuffix(String word, String suffix, String replacement) {
    assert(word.endsWith(suffix)); // Given word doesn't end with given suffix
    if (suffix == '') {
      return word + replacement;
    } else {
      return word.substring(0, word.length - suffix.length) + replacement;
    }
  }

  /// Applies the first applicable suffix-removal rule to the word
  ///
  /// Takes a word and a list of suffix-removal rules represented as
  /// 3-tuples, with the first element being the suffix to remove,
  /// the second element being the string to replace it with, and the
  /// final element being the condition for the rule to be applicable,
  /// or None if the rule is unconditional.
  String _applyRuleList(String word, List<List> rules) {
    for (List rule in rules) {
      String suffix = rule[0];
      String replacement = rule[1];
      Function condition = rule[2];

      String stem;
      if (suffix == '*d' && _endsDoubleConsonant(word)) {
        stem = word.substring(0, word.length - 2);
        if (condition == null || condition(stem)) {
          return stem + replacement;
        } else {
          // Don't try any further rules
          return word;
        }
      }
      if (word.endsWith(suffix)) {
        stem = _replaceSuffix(word, suffix, '');
        if (condition == null || condition(stem)) {
          return stem + replacement;
        } else {
          // Don't try any further rules
          return word;
        }
      }
    }

    return word;
  }

  /// Implements Step 1a from "An algorithm for suffix stripping"
  ///
  /// From the paper:
  ///
  ///     SSES -> SS                         caresses  ->  caress
  ///     IES  -> I                          ponies    ->  poni
  ///                                        ties      ->  ti
  ///     SS   -> SS                         caress    ->  caress
  ///     S    ->                            cats      ->  cat
  ///
  /// This NLTK-only rule extends the original algorithm, so
  /// that `flies`->`fli` but `dies`->`die` etc
  String _step1a(String word) {
    if (word.endsWith('ies') && word.length == 4) {
      return _replaceSuffix(word, 'ies', 'ie');
    }

    return _applyRuleList(
      word,
      [
        ['sses', 'ss', null], // SSES -> SS
        ['ies', 'i', null], // IES  -> I
        ['ss', 'ss', null], // SS   -> SS
        ['s', '', null], // S    ->
      ],
    );
  }

  /// Implements Step 1b from "An algorithm for suffix stripping"
  ///
  /// From the paper:
  ///
  ///     (m>0) EED -> EE                    feed      ->  feed
  ///                                        agreed    ->  agree
  ///     (*v*) ED  ->                       plastered ->  plaster
  ///                                        bled      ->  bled
  ///     (*v*) ING ->                       motoring  ->  motor
  ///                                        sing      ->  sing
  ///
  /// If the second or third of the rules in Step 1b is successful,
  /// the following is done:
  ///
  ///     AT -> ATE                       conflat(ed)  ->  conflate
  ///     BL -> BLE                       troubl(ed)   ->  trouble
  ///     IZ -> IZE                       siz(ed)      ->  size
  ///     (*d and not (*L or *S or *Z))
  ///        -> single letter
  ///                                     hopp(ing)    ->  hop
  ///                                     tann(ed)     ->  tan
  ///                                     fall(ing)    ->  fall
  ///                                     hiss(ing)    ->  hiss
  ///                                     fizz(ed)     ->  fizz
  ///     (m=1 and *o) -> E               fail(ing)    ->  fail
  ///                                     fil(ing)     ->  file
  ///
  /// The rule to map to a single letter causes the removal of one of
  /// the double letter pair. The -E is put back on -AT, -BL and -IZ,
  /// so that the suffixes -ATE, -BLE and -IZE can be recognised
  /// later. This E may be removed in step 4.
  ///
  /// This NLTK-only block extends the original algorithm, so that
  /// `spied`->`spi` but `died`->`die` etc
  String _step1b(String word) {
    if (word.endsWith('ied')) {
      if (word.length == 4) {
        return _replaceSuffix(word, 'ied', 'ie');
      } else {
        return _replaceSuffix(word, 'ied', 'i');
      }
    }

    // (m>0) EED -> EE
    if (word.endsWith('eed')) {
      String stem = _replaceSuffix(word, 'eed', '');
      if (_measure(stem) > 0) {
        return stem + 'ee';
      } else {
        return word;
      }
    }

    bool rule2Or3Succeeded = false;

    String intermediateStem;
    for (String suffix in ['ed', 'ing']) {
      if (word.endsWith(suffix)) {
        intermediateStem = _replaceSuffix(word, suffix, '');
        if (_containsVowel(intermediateStem)) {
          rule2Or3Succeeded = true;
          break;
        }
      }
    }

    if (!rule2Or3Succeeded) {
      return word;
    }

    return _applyRuleList(
      intermediateStem,
      [
        ['at', 'ate', null], // AT -> ATE
        ['bl', 'ble', null], // BL -> BLE
        ['iz', 'ize', null], // IZ -> IZE
        // (*d and not (*L or *S or *Z))
        // -> single letter
        [
          '*d',
          intermediateStem[intermediateStem.length - 1],
          (String stem) => !(['l', 's', 'z']
              .contains(intermediateStem[intermediateStem.length - 1])),
        ],
        // (m=1 and *o) -> E
        [
          '',
          'e',
          (String stem) => _measure(stem) == 1 && _endsCvc(stem),
        ],
      ],
    );
  }

  /// Implements Step 1c from "An algorithm for suffix stripping"
  ///
  /// From the paper:
  ///
  /// Step 1c
  ///
  ///     (*v*) Y -> I                    happy        ->  happi
  ///                                     sky          ->  sky

  String _step1c(String word) {
    /// This has been modified from the original Porter algorithm so
    /// that y->i is only done when y is preceded by a consonant,
    /// but not if the stem is only a single consonant, i.e.
    ///
    ///    (*c and not c) Y -> I
    ///
    /// So 'happy' -> 'happi', but
    ///    'enjoy' -> 'enjoy'  etc
    ///
    /// This is a much better rule. Formerly 'enjoy'->'enjoi' and
    /// 'enjoyment'->'enjoy'. Step 1c is perhaps done too soon; but
    /// with this modification that no longer really matters.
    ///
    /// Also, the removal of the contains_vowel(z) condition means
    /// that 'spy', 'fly', 'try' ... stem to 'spi', 'fli', 'tri' and
    /// conflate with 'spied', 'tried', 'flies' ...
    bool nltkCondition(String stem) {
      return stem.length > 1 && _isConsonant(stem, stem.length - 1);
    }

    return _applyRuleList(
      word,
      [
        ['y', 'i', nltkCondition]
      ],
    );
  }

  /// Implements Step 2 from "An algorithm for suffix stripping"
  ///
  /// From the paper:
  ///
  /// Step 2
  ///
  ///     (m>0) ATIONAL ->  ATE       relational     ->  relate
  ///     (m>0) TIONAL  ->  TION      conditional    ->  condition
  ///                                 rational       ->  rational
  ///     (m>0) ENCI    ->  ENCE      valenci        ->  valence
  ///     (m>0) ANCI    ->  ANCE      hesitanci      ->  hesitance
  ///     (m>0) IZER    ->  IZE       digitizer      ->  digitize
  ///     (m>0) ABLI    ->  ABLE      conformabli    ->  conformable
  ///     (m>0) ALLI    ->  AL        radicalli      ->  radical
  ///     (m>0) ENTLI   ->  ENT       differentli    ->  different
  ///     (m>0) ELI     ->  E         vileli        - >  vile
  ///     (m>0) OUSLI   ->  OUS       analogousli    ->  analogous
  ///     (m>0) IZATION ->  IZE       vietnamization ->  vietnamize
  ///     (m>0) ATION   ->  ATE       predication    ->  predicate
  ///     (m>0) ATOR    ->  ATE       operator       ->  operate
  ///     (m>0) ALISM   ->  AL        feudalism      ->  feudal
  ///     (m>0) IVENESS ->  IVE       decisiveness   ->  decisive
  ///     (m>0) FULNESS ->  FUL       hopefulness    ->  hopeful
  ///     (m>0) OUSNESS ->  OUS       callousness    ->  callous
  ///     (m>0) ALITI   ->  AL        formaliti      ->  formal
  ///     (m>0) IVITI   ->  IVE       sensitiviti    ->  sensitive
  ///     (m>0) BILITI  ->  BLE       sensibiliti    ->  sensible

  // Instead of applying the ALLI -> AL rule after '(a)bli' per
  // the published algorithm, instead we apply it first, and,
  // if it succeeds, run the result through step2 again.
  String _step2(String word) {
    if (word.endsWith('alli') &&
        _hasPositiveMeasure(_replaceSuffix(word, 'alli', ''))) {
      return _step2(_replaceSuffix(word, 'alli', 'al'));
    }

    List<List> rules = [
      ['ational', 'ate', _hasPositiveMeasure],
      ['tional', 'tion', _hasPositiveMeasure],
      ['enci', 'ence', _hasPositiveMeasure],
      ['anci', 'ance', _hasPositiveMeasure],
      ['izer', 'ize', _hasPositiveMeasure],
      ['bli', 'ble', _hasPositiveMeasure],
      ['alli', 'al', _hasPositiveMeasure],
      ['entli', 'ent', _hasPositiveMeasure],
      ['eli', 'e', _hasPositiveMeasure],
      ['ousli', 'ous', _hasPositiveMeasure],
      ['ization', 'ize', _hasPositiveMeasure],
      ['ation', 'ate', _hasPositiveMeasure],
      ['ator', 'ate', _hasPositiveMeasure],
      ['alism', 'al', _hasPositiveMeasure],
      ['iveness', 'ive', _hasPositiveMeasure],
      ['fulness', 'ful', _hasPositiveMeasure],
      ['ousness', 'ous', _hasPositiveMeasure],
      ['aliti', 'al', _hasPositiveMeasure],
      ['iviti', 'ive', _hasPositiveMeasure],
      ['biliti', 'ble', _hasPositiveMeasure],
      ['fulli', 'ful', _hasPositiveMeasure],
      // The 'l' of the 'logi' -> 'log' rule is put with the stem,
      // so that short stems like 'geo' 'theo' etc work like
      // 'archaeo' 'philo' etc.
      [
        "logi",
        "log",
        (String stem) => _hasPositiveMeasure(word.substring(0, word.length - 3))
      ]
    ];

    return _applyRuleList(word, rules);
  }

  /// Implements Step 3 from "An algorithm for suffix stripping"
  ///
  /// From the paper:
  ///
  /// Step 3
  ///
  ///     (m>0) ICATE ->  IC              triplicate     ->  triplic
  ///     (m>0) ATIVE ->                  formative      ->  form
  ///     (m>0) ALIZE ->  AL              formalize      ->  formal
  ///     (m>0) ICITI ->  IC              electriciti    ->  electric
  ///     (m>0) ICAL  ->  IC              electrical     ->  electric
  ///     (m>0) FUL   ->                  hopeful        ->  hope
  ///     (m>0) NESS  ->                  goodness       ->  good
  String _step3(String word) {
    return _applyRuleList(
      word,
      [
        ['icate', 'ic', _hasPositiveMeasure],
        ['ative', '', _hasPositiveMeasure],
        ['alize', 'al', _hasPositiveMeasure],
        ['iciti', 'ic', _hasPositiveMeasure],
        ['ical', 'ic', _hasPositiveMeasure],
        ['ful', '', _hasPositiveMeasure],
        ['ness', '', _hasPositiveMeasure],
      ],
    );
  }

  /// Implements Step 4 from "An algorithm for suffix stripping"
  ///
  /// Step 4
  ///
  ///     (m>1) AL    ->                  revival        ->  reviv
  ///     (m>1) ANCE  ->                  allowance      ->  allow
  ///     (m>1) ENCE  ->                  inference      ->  infer
  ///     (m>1) ER    ->                  airliner       ->  airlin
  ///     (m>1) IC    ->                  gyroscopic     ->  gyroscop
  ///     (m>1) ABLE  ->                  adjustable     ->  adjust
  ///     (m>1) IBLE  ->                  defensible     ->  defens
  ///     (m>1) ANT   ->                  irritant       ->  irrit
  ///     (m>1) EMENT ->                  replacement    ->  replac
  ///     (m>1) MENT  ->                  adjustment     ->  adjust
  ///     (m>1) ENT   ->                  dependent      ->  depend
  ///     (m>1 and (*S or *T)) ION ->     adoption       ->  adopt
  ///     (m>1) OU    ->                  homologou      ->  homolog
  ///     (m>1) ISM   ->                  communism      ->  commun
  ///     (m>1) ATE   ->                  activate       ->  activ
  ///     (m>1) ITI   ->                  angulariti     ->  angular
  ///     (m>1) OUS   ->                  homologous     ->  homolog
  ///     (m>1) IVE   ->                  effective      ->  effect
  ///     (m>1) IZE   ->                  bowdlerize     ->  bowdler
  ///
  /// The suffixes are now removed. All that remains is a little
  /// tidying up.
  String _step4(String word) {
    Function measureGt1 = (String stem) => _measure(stem) > 1;

    return _applyRuleList(
      word,
      [
        ['al', '', measureGt1],
        ['ance', '', measureGt1],
        ['ence', '', measureGt1],
        ['er', '', measureGt1],
        ['ic', '', measureGt1],
        ['able', '', measureGt1],
        ['ible', '', measureGt1],
        ['ant', '', measureGt1],
        ['ement', '', measureGt1],
        ['ment', '', measureGt1],
        ['ent', '', measureGt1],
        // (m>1 and (*S or *T)) ION ->
        [
          'ion',
          '',
          (String stem) =>
              _measure(stem) > 1 && ['s', 't'].contains(stem[stem.length - 1]),
        ],
        ['ou', '', measureGt1],
        ['ism', '', measureGt1],
        ['ate', '', measureGt1],
        ['iti', '', measureGt1],
        ['ous', '', measureGt1],
        ['ive', '', measureGt1],
        ['ize', '', measureGt1],
      ],
    );
  }

  /// Implements Step 5a from "An algorithm for suffix stripping"
  ///
  /// From the paper:
  ///
  /// Step 5a
  ///
  ///     (m>1) E     ->                  probate        ->  probat
  ///                                     rate           ->  rate
  ///     (m=1 and not *o) E ->           cease          ->  ceas
  ///
  /// Note that Martin's test vocabulary and reference
  /// implementations are inconsistent in how they handle the case
  /// where two rules both refer to a suffix that matches the word
  /// to be stemmed, but only the condition of the second one is
  /// true.
  ///
  /// Earlier in step2b we had the rules:
  ///     (m>0) EED -> EE
  ///     (*v*) ED  ->
  ///
  /// but the examples in the paper included `feed`->`feed`, even
  /// though (*v*) is true for `fe` and therefore the second rule
  /// alone would map `feed`->`fe`.
  /// However, in THIS case, we need to handle the consecutive rules
  /// differently and try both conditions (obviously; the second
  /// rule here would be redundant otherwise). Martin's paper makes
  /// no explicit mention of the inconsistency; you have to infer it
  /// from the examples.
  ///
  /// For this reason, we can't use _apply_rule_list here.
  String _step5a(String word) {
    if (word.endsWith('e')) {
      String stem = _replaceSuffix(word, 'e', '');
      if (_measure(stem) > 1) {
        return stem;
      }
      if (_measure(stem) == 1 && !_endsCvc(stem)) {
        return stem;
      }
    }
    return word;
  }

  /// Implements Step 5a from "An algorithm for suffix stripping"
  ///
  /// From the paper:
  ///
  /// Step 5b
  ///
  ///     (m > 1 and *d and *L) -> single letter
  ///                             controll       ->  control
  ///                             roll           ->  roll
  String _step5b(String word) {
    return _applyRuleList(word, [
      [
        'll',
        'l',
        (String stem) => _measure(word.substring(0, word.length - 1)) > 1
      ]
    ]);
  }

  /// Stems [word]. Only stems words that are at least 3 characters,
  /// otherwise will return [word].
  String stem(String word) {
    String stem = word.toLowerCase();

    if (_pool.containsKey(word)) {
      return _pool[word];
    }

    if (word.length <= 2) {
      // With this line, strings of length 1 or 2 don't go through
      // the stemming process, although no mention is made of this
      // in the published algorithm.
      return word;
    }

    stem = _step1a(stem);
    stem = _step1b(stem);
    stem = _step1c(stem);
    stem = _step2(stem);
    stem = _step3(stem);
    stem = _step4(stem);
    stem = _step5a(stem);
    stem = _step5b(stem);

    return stem;
  }
}
