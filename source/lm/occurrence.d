module lm.occurrence;

import std.stdio : File;
import std.conv : to;
import core.exception : RangeError;

import morphemes.parser : MorphemeList, SentenceParser, toWords;
import lm.languagemodel : WordFrequency;


alias Count = ulong[string];


/**
Count the number of occurrences of words in a given sentence.
*/
class Occurrence : WordFrequency {
    //occurence[word] keeps how many times word found
    private Count occurence;

    /// sentence: a list of words which forms a sentence
    void update(string[] sentence) {
        foreach(word; sentence) {
            this.occurence[word] += 1;
        }
    }

    ///Returns:
    ///The associative array which keys are the words found in the sentence and
    ///the values are the numbers of occurences of associated words.
    Count dump() {
        return this.occurence;
    }
}

unittest {
    string sentence = "この先、生きのこる。この先生、きのこる。";
    auto morphemes = new SentenceParser().parse(sentence);
    string[] words = morphemes.toWords();
    Occurrence occurence = new Occurrence();
    occurence.update(words);

    Count result = [
        "この": 2, "先":1, "、":2, "生き":1, "のこる":1,
        "先生":1, "きのこ":1, "る":1, "。":2];

    assert(occurence.dump() == result);
}
