import std.stdio;
import std.array : split;
import std.conv : to;

import morphemes.parser : SentenceParser, MorphemeList, toWords;
import lm.occurrence : Occurrence;
import lm.cooccurrence : Cooccurrence;
import lm.bigram : BigramBuilder;
import lm.word_class_bigram : WordClassBigramBuilder;


void train(string path) {
    Cooccurrence cooccurrence = new Cooccurrence();
    Occurrence occurrence = new Occurrence();
    SentenceParser parser = new SentenceParser();
    auto bigram_builder = new BigramBuilder();
    auto word_class_bigram_builder = new WordClassBigramBuilder();

    auto file = File(path);
    foreach(line; file.byLine()) {
        MorphemeList morphemes = parser.parse(to!string(line));
        string[] sentence = morphemes.toWords();

        word_class_bigram_builder.update(morphemes);
        bigram_builder.update(sentence);

        cooccurrence.update(sentence);
        occurrence.update(sentence);
    }

    auto bigram = bigram_builder.build();
    auto word_class_bigram = word_class_bigram_builder.build();
}


void lattice() {
}


void shortestPath() {
}


void main(string[] args) {
    train("dataset/corpus/jawiki-20151002-pages-articles1.xml-01.txt");
    //lattice();
    //shortestPath();
}
