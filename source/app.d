import std.stdio;
import std.array : split;

import lm.languagemodel : WordFrequency, Bigram;
import lm.builder : LanguageModelBuilder;

void lattice(string sentence) {
}


void shortestPath() {
}


void main(string[] args) {
    auto builder = new LanguageModelBuilder();
    builder.update("dataset/corpus/jawiki-20151002-pages-articles1.xml-01.txt");
    builder.update("dataset/corpus/jawiki-20151002-pages-articles1.xml-02.txt");
    builder.update("dataset/corpus/jawiki-20151002-pages-articles1.xml-03.txt");
    auto t = builder.build();
    WordFrequency word_frequency = t[0];
    Bigram bigram = t[1];

    //lattice();
    //shortestPath();
}
