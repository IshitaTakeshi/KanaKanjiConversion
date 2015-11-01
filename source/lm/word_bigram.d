module lm.word_bigram;

import std.stdio;
import std.conv : to;

import lm.languagemodel : Bigram, BigramBuilder;


alias Count = ulong[string][string];


class WordBigram : Bigram {
    Count bigram;

    this() {
    }

    Count dump() {
        return this.bigram;
    }

    void update(string current_word, string next_word) {
        this.bigram[current_word][next_word] += 1;
    }

    override bool opEquals(Object o) {
        auto bigram = cast(WordBigram)o;
        return (this.dump() == bigram.dump());
    }

    override string toString() {
        return to!string(this.bigram);
    }
}


class WordBigramBuilder : BigramBuilder {
    WordBigram bigram;

    this() {
        this.bigram = new WordBigram();
    }

    void update(string[] words) {
        auto bigram = new WordBigram();
        for(int i = 0; i < words.length-1; i++) {
            string current = words[i];
            string next = words[i+1];
            this.bigram.update(current, next);
        }
    }

    WordBigram build() {
        return this.bigram;
    }
}

unittest {
    string[] words = ["すもも", "も", "もも", "も", "もも", "の", "うち"];

    auto builder = new WordBigramBuilder();
    builder.update(words);
    WordBigram bigram = builder.build();

    Count count;
    count["すもも"]["も"] += 1;
    count["も"]["もも"] += 1;
    count["もも"]["も"] += 1;
    count["も"]["もも"] += 1;
    count["もも"]["の"] += 1;
    count["の"]["うち"] += 1;
    assert(bigram.dump() == count);
}
