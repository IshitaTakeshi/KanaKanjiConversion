import std.typecons : tuple, Tuple;
import std.conv : to;
import std.string : toStringz;
import core.exception : RangeError;

import parser : SentenceParser, MorphemeList, Morpheme;
import word_class : N_CLASSES, WORD_CLASSES;


//TODO write documentations

/*
Assume that we see a sentence "スモモも桃も桃のうち".
The word classes of the sentence will be like this.

名詞    助詞  名詞  助詞  名詞  助詞  名詞
スモモ  も    桃    も    桃    の    うち

The number of occurrences of transition from 名詞 to 助詞 is 3 as we can see
above.
Then

--------------------
BIGRAM word_class_count;
word_class_count[11][5] = 3;
--------------------

because 名詞 is the 11th element of word classes and 助詞 is the 5th.
In like manner, transition from 助詞 to 名詞 is also counted.

--------------------
word_class_count[5][11] = 3;
--------------------

Elements of word_class_count are initialized to 0 when allocated, so elements
other than word_class_count[11][5] and word_class_count[5][11] are 0.
 */
alias BIGRAM = ulong[N_CLASSES][N_CLASSES];


/* Class to keep a bigram. */
class Bigram {
    private BIGRAM word_class_count;

    this() {
    }

    @property BIGRAM wordClassCount() {
        return this.word_class_count;
    }

    /*
    Merge another Bigram to this.
     */
    void add(Bigram bigram) {
        BIGRAM count = bigram.wordClassCount;
        foreach(int i, ref counts; this.word_class_count) {
            foreach(int j, ref e; counts) {
                e += count[i][j];
            }
        }
    }

    unittest {
        auto builder = new BigramBuilder();
        string sentence = "すもももももももものうち";
        Bigram bigram1 = builder.parse(sentence);
        Bigram bigram2 = builder.parse(sentence);

        bigram1.add(bigram2);

        //import std.stdio;
        //writeln(bigram1);
        BIGRAM word_class_count;
        word_class_count[11][5] = 6;
        word_class_count[5][11] = 6;
        assert(bigram1.wordClassCount == word_class_count);
    }

    void incrementWordCount(uint current_index, uint next_index) {
        this.word_class_count[current_index][next_index] += 1;
    }

    override string toString() {
        import std.string : format;
        import std.array : replicate, join;

        string[] lines = [];
        for(auto i = 0; i < N_CLASSES; i++) {
            for(auto j = 0; j < N_CLASSES; j++) {
                auto count = this.word_class_count[i][j];
                if(count == 0) {
                    continue;
                }

                auto m = WORD_CLASSES[i];
                auto n = WORD_CLASSES[j];
                lines ~= format("%s%s   ->   %s%s   : %8d",
                                m, "  ".replicate(4-m.length),
                                n, "  ".replicate(4-n.length),
                                count);
            }
        }
        return join(lines, "\n");
    }
}



class BigramBuilder {
    this() {
    }

    /*
       Parse a sentence and returns a Bigram object.
       */
    Bigram parse(string sentence)
    body {
        import std.stdio;
        Bigram bigram = new Bigram();
        SentenceParser parser = new SentenceParser();
        MorphemeList morphemes  = parser.parse(sentence);


        Morpheme previous = null;
        foreach(morpheme; morphemes) {
            if(previous is null) {
                previous = morpheme;
                continue;
            }

            uint p = previous.wordClassIndex;
            uint c = morpheme.wordClassIndex;
            bigram.incrementWordCount(p, c);
            previous = morpheme;
        }
        return bigram;
    }

    ///
    unittest {
        auto builder = new BigramBuilder();
        Bigram bigram = builder.parse("すもももももももものうち");

        BIGRAM word_class_count;
        word_class_count[11][5] = 3;
        word_class_count[5][11] = 3;

        assert(bigram.wordClassCount == word_class_count);
    }

    unittest {
        auto builder = new BigramBuilder();
        Bigram bigram = builder.parse("台湾に行きたいワン");

        BIGRAM word_class_count;
        word_class_count[11][5] = 1;  //名詞 -> 助詞
        word_class_count[5][9] = 1;   //助詞 -> 動詞
        word_class_count[9][6] = 1;   //動詞 -> 助動詞
        word_class_count[6][11] = 1;  //助動詞 -> 名詞

        assert(bigram.wordClassCount == word_class_count);
    }
}
