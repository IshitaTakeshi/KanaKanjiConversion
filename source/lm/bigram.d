module lm.bigram;

import std.stdio;

import lm.abstractbigram : AbstractBigram, AbstractBigramBuilder;


alias Count = ulong[string][string];


class Bigram : AbstractBigram {
    Count bigram;

    this() {
    }

    Count dump() {
        return this.bigram;
    }

    void update(string current_word, string next_word) {
        this.bigram[current_word][next_word] += 1;
    }
}


class BigramBuilder : AbstractBigramBuilder {
    Bigram bigram;

    this() {
        this.bigram = new Bigram();
    }

    void update(string[] words) {
        auto bigram = new Bigram();
        for(int i = 0; i < words.length-1; i++) {
            string current = words[i];
            string next = words[i+1];
            this.bigram.update(current, next);
        }
    }

    Bigram build() {
        return this.bigram;
    }
}

unittest {
    string[] words = ["すもも", "も", "もも", "も", "もも", "の", "うち"];

    auto builder = new BigramBuilder();
    builder.update(words);
    Bigram bigram = builder.build();

    Count count;
    count["すもも"]["も"] += 1;
    count["も"]["もも"] += 1;
    count["もも"]["も"] += 1;
    count["も"]["もも"] += 1;
    count["もも"]["の"] += 1;
    count["の"]["うち"] += 1;
    assert(bigram.dump() == count);
}
