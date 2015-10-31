module lm.abstractbigram;

interface AbstractBigram {
    void update(T)(T current, T next);
}

interface AbstractBigramBuilder {
    void update(T)(T words);
    AbstractBigram build();
}
