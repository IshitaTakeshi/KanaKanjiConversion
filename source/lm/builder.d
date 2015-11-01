module lm.builder;

import std.stdio;
import std.typecons : Tuple, tuple;
import std.conv : to;

import morphemes.parser : SentenceParser, MorphemeList, toWords;
import lm.languagemodel : WordFrequency, Bigram, BigramBuilder;
import lm.occurrence : Occurrence;
import lm.cooccurrence : Cooccurrence;
import lm.word_bigram : WordBigramBuilder;
import lm.word_class_bigram : WordClassBigramBuilder;

/*
void build(string filename) {
    auto occurrence = new Occurrence();
    auto builder = new BigramBuilder();

    SentenceParser parser = new SentenceParser();
    auto file = File(filename);
    foreach(line; file.byLine) {
        MorphemeList morphemes = parser.parse(to!string(line));
        auto sentence = morphemes.toWords();

        occurrence.update(sentence);
        builder.update(sentence);
    }
}
*/


class LanguageModelBuilder {
    Occurrence occurrence;
    Cooccurrence cooccurrence;
    WordBigramBuilder builder;
    SentenceParser parser;

    this() {
        this.cooccurrence = new Cooccurrence();
        this.occurrence = new Occurrence();
        this.builder = new WordBigramBuilder();
        this.parser = new SentenceParser();
    }

    void update(string filename) {
        auto file = File(filename);
        foreach(line; file.byLine()) {
            MorphemeList morphemes = this.parser.parse(to!string(line));
            auto sentence = morphemes.toWords();

            this.cooccurrence.update(sentence);
            this.occurrence.update(sentence);
            this.builder.update(sentence);
        }
    }

    Tuple!(WordFrequency, Bigram) build() {
        auto bigram = this.builder.build();
        //TODO check if new memory allocation occures
        return tuple(cast(WordFrequency)this.occurrence,
                     cast(Bigram)bigram);
    }
}

