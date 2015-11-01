module lm.languagemodel;


interface Bigram {
    void update(T)(T current, T next);
    T dump(T)();
}


interface WordFrequency {
    void update(string[] sentence);
    T dump(T)();
}


interface BigramBuilder {
    void update(T)(T words);
    Bigram build();
}
