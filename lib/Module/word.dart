enum Typeword {
  noun,
  pronoun,
  adjective,
  verb,
  adverb,
  determiner,
  preposition,
  conjunction,
  interjection,
  undefined,
  phrasal_verb
}

Typeword convertStringToEnum(String str) {
  switch (str) {
    case 'noun':
      return Typeword.noun;
    case 'pronoun':
      return Typeword.pronoun;
    case 'adjective':
      return Typeword.adjective;
    case 'verb':
      return Typeword.verb;
    case 'adverb':
      return Typeword.adverb;
    case 'determiner':
      return Typeword.determiner;
    case 'preposition':
      return Typeword.preposition;
    case 'conjunction':
      return Typeword.conjunction;
    case 'interjection':
      return Typeword.interjection;
    case 'undefined':
      return Typeword.undefined;
    case 'phrasal_verb':
      return Typeword.phrasal_verb;
    default:
      return Typeword.undefined; // Hoặc bạn có thể chọn một giá trị mặc định khác nếu cần
  }
}

class Word{
  String word;
  Typeword type;
  String linkUS, linkUK;
  String phonicUS, phonicUK;
  String means;
  String example;

  Word({
    required this.word,
    required this.type,
    required this.linkUK,
    required this.linkUS,
    required this.phonicUK,
    required this.phonicUS,
    required this.means,
    required this.example
  });
}