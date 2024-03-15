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