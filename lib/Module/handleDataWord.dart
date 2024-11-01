import 'dart:convert';

import 'package:appenglish/Module/word.dart';
import 'package:http/http.dart' as http;
import 'meanWord.dart';

class handleDataWord{

  /// Retrieves the `Typeword` enum value that matches the given string `name`.
  /// Throws an exception if no match is found
  Typeword getEnumValue(String name) {
    for (var enumValue in Typeword.values) {
      if (enumValue.toString().split('.').last == name) {
        return enumValue;
      }
    }
    throw Exception("no have found enum for string '$name'");
  }

  /// Parses the `value` map to find a definition and example for the word type.
  /// If an example is found, returns a `meanWord` instance with the type, definition, and example.
  /// If no example is found, returns the first available definition with an empty example.
  meanWord? hanldTypeword(Map<String, dynamic> value){
    for(var type in value.keys){
      for(var time in value[type]){
        if((time as Map).containsKey("example")){
          return meanWord(definition: (time as Map)["definition"], example: (time as Map)["example"], type: type);
        }
      }
    }
    // Return the first definition found if no example is available
    var test = meanWord(definition: ((value[(value.keys).first] as List)[0] as Map)["definition"], example: "", type: value.keys.first);
    return test;
  }

  /// Fetches an example sentence for the specified `word` from the Urban Dictionary API.
  /// Returns the example if successful, an empty string if the request fails, or "error" on exception.
  Future<String> createExampleWord(String word) async {
    try {
      final response = await http.get(Uri.parse('https://api.urbandictionary.com/v0/define?term=${word}'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return ((data["list"] as List)[3] as Map)["example"];
      } else {
        return "";
      }
    } catch (error) {
      return "error";
    }
  }

  /// Assembles a `Word` object using the parsed `data` and `word` string.
  /// Selects the appropriate UK and US phonetic audio links and texts.
  /// If a definition and example are found, they are included in the `Word` object.
  /// Otherwise, attempts to create an example using `createExampleWord`.
  Future<Word> getWord(data, String word) async {
    print(word);
    return ((data[0] as Map)["phonetics"] as List).length <= 2 ? Word(
        word: word,
        type: getEnumValue(
            hanldTypeword((data[0] as Map)["meaning"])!.type),
        linkUK: (data[0] as Map)["phonetics"][0]["audio"],
        linkUS: ((data[0] as Map)["phonetics"] as List).length == 2
            ? (data[0] as Map)["phonetics"][1]["audio"]
            : (data[0] as Map)["phonetics"][0]["audio"],
        phonicUK: (data[0] as Map)["phonetics"][0]["text"],
        phonicUS: ((data[0] as Map)["phonetics"] as List).length == 2
            ? (data[0] as Map)["phonetics"][1]["text"]
            : (data[0] as Map)["phonetics"][0]["text"],
        means: hanldTypeword((data[0] as Map)["meaning"]) != null
            ? hanldTypeword((data[0] as Map)["meaning"])!.definition
            : "",
        example: hanldTypeword((data[0] as Map)["meaning"]) != null
            ? hanldTypeword((data[0] as Map)["meaning"])!.example
            : (await createExampleWord(word))
    ) : Word(
        word: word,
        type: getEnumValue(
            hanldTypeword((data[0] as Map)["meaning"])!.type),
        linkUK: (data[0] as Map)["phonetics"][1]["audio"],
        linkUS: (data[0] as Map)["phonetics"][2]["audio"],
        phonicUK: (data[0] as Map)["phonetics"][1]["text"],
        phonicUS: (data[0] as Map)["phonetics"][2]["text"],
        means: hanldTypeword((data[0] as Map)["meaning"]) != null
            ? hanldTypeword((data[0] as Map)["meaning"])!.definition
            : "",
        example: hanldTypeword((data[0] as Map)["meaning"]) != null
            ? hanldTypeword((data[0] as Map)["meaning"])!.example
            : (await createExampleWord(word))
    );
  }
}