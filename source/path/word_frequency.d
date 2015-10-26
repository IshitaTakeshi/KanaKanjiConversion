module path.word_frequency;

import std.stdio : File;
import std.conv : to;
import core.exception : RangeError;

import path.parser : MorphemeList, SentenceParser;


/**
Count the number of occurrences of words in a given sentence.

Parameters:
sentence = the sentence to be analyzed.
Returns:
The associative array which keys are the words exist in the sentence and the
values are the numbers of occurences of associated words.
*/
ulong[string] countWordFrequency(string sentence) {
    ulong[string] word_frequency;

    auto parser = new SentenceParser();

    MorphemeList morphemes = parser.parse(sentence.to!string);
    foreach(morpheme; morphemes) {
        word_frequency[morpheme.word] += 1;
    }

    return word_frequency;
}


unittest {
    string sentence = "この先、生きのこる。この先生、きのこる。";
    ulong[string] frequency = countWordFrequency(sentence);

    ulong[string] result = [
        "この": 2, "先":1, "、":2, "生き":1, "のこる":1,
        "先生":1, "きのこ":1, "る":1, "。":2];

    assert(frequency == result);
}
