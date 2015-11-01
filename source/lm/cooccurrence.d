module lm.cooccurrence;

import std.container : make, RedBlackTree;

import lm.languagemodel : WordFrequency;


alias Set = RedBlackTree!string;
alias Count = ulong[string][string];


class Cooccurrence : WordFrequency {
    //cooccurrence[A][B] keeps how many times word A and word B co-occured
    private Count cooccurrence;

    ///sentence: a list of words which forms a sentence
    void update(string[] sentence) {
        auto words = make!(Set)(sentence);
        foreach(a; words) {
            foreach(b; words) {
                this.cooccurrence[a][b] += 1;
            }
        }
    }

    Count dump() {
        return this.cooccurrence;
    }
}
