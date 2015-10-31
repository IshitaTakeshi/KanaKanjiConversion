module lm.word_class_bigram;

import std.algorithm.iteration : map;
import std.array : array, join, replace, replicate, split;
import std.conv : to;
import std.file : exists, remove;
import std.stdio;
import std.string : format, toStringz;
import std.typecons : tuple, Tuple;
import core.exception : RangeError;

import morphemes.parser : SentenceParser, MorphemeList, Morpheme;
import morphemes.word_class : N_CLASSES, WORD_CLASSES;
import lm.abstractbigram : AbstractBigram, AbstractBigramBuilder;

//TODO write documentations

/**
Assume that we see a sentence "スモモも桃も桃のうち".
The word classes of the sentence will be like this.

名詞    助詞  名詞  助詞  名詞  助詞  名詞
スモモ  も    桃    も    桃    の    うち

The number of occurrences of transition from 名詞 to 助詞 is 3 as we can see
above.
Then

--------------------
Count word_class_count;
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
alias Count = ulong[N_CLASSES][N_CLASSES];


/**
Class to keep a bigram.
*/
class WordClassBigram : AbstractBigram {
    private Count word_class_count;

    @property Count dump() {
        return this.word_class_count;
    }

    void update(uint current_index, uint next_index) {
        this.word_class_count[current_index][next_index] += 1;
    }

    ///
    unittest {
        auto bigram = new WordClassBigram();
        bigram.update(11, 5);
        bigram.update(5, 11);

        Count word_class_count;
        word_class_count[11][5] = 1;
        word_class_count[5][11] = 1;

        assert(bigram.dump() == word_class_count);
    }

    override bool opEquals(Object o) {
        auto bigram = cast(WordClassBigram)o;
        return (this.dump() == bigram.dump());
    }

    override string toString() {
        string[] lines = [];
        for(auto i = 0; i < N_CLASSES; i++) {
            for(auto j = 0; j < N_CLASSES; j++) {
                auto count = this.word_class_count[i][j];
                //do not show if the count is 0
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

    /*
    void write(string filename) {
        string arrayToLine(ulong[] array) {
            string[] line;
            foreach(ref e; array) {
                line ~= e.to!string;
            }
            return line.join(",");
        }

        auto file = File(filename, "w");
        foreach(array; this.word_class_count) {
            file.writeln(arrayToLine(array));
        }
        file.close();
    }

    void load(string filename) {
        auto file = File(filename, "r");

        auto i = 0;
        string line = file.readln().replace("\n", "");
        while(line !is null) {
            auto a = array(map!(to!ulong)(line.split(",")));
            this.word_class_count[i][0..$] = a;

            i += 1;
            line = file.readln().replace("\n", "");
        }
    }

    unittest {
        auto builder = new WordClassBigramBuilder();
        auto loader = new WordClassBigram();

        builder.update("すもももももももものうち");
        builder.update("この先生きのこる");
        auto bigram = builder.build();

        string filename = "test.csv";
        while(exists(filename)) {
            filename ~= ".test";
        }

        bigram.write(filename);
        loader.load(filename);
        assert(bigram == loader);

        remove(filename);
    }
    */
}


///
class WordClassBigramBuilder : AbstractBigramBuilder {
    WordClassBigram bigram;

    this() {
        this.bigram = new WordClassBigram();
    }

    /**
    Parse a sentence and returns a WordClassBigram object.
    */
    void update(MorphemeList morphemes)
    body {
        Morpheme previous = null;
        foreach(morpheme; morphemes) {
            if(previous is null) {
                previous = morpheme;
                continue;
            }

            uint p = previous.wordClassIndex;
            uint c = morpheme.wordClassIndex;

            this.bigram.update(p, c);
            previous = morpheme;
        }
    }

    ///
    unittest {
        auto builder = new WordClassBigramBuilder();
        auto parser = new SentenceParser();
        auto morphemes = parser.parse("すもももももももものうち");
        builder.update(morphemes);
        WordClassBigram bigram = builder.build();

        Count word_class_count;
        word_class_count[11][5] = 3;
        word_class_count[5][11] = 3;

        assert(bigram.dump() == word_class_count);
    }

    unittest {
        auto builder = new WordClassBigramBuilder();
        auto parser = new SentenceParser();
        auto morphemes = parser.parse("台湾に行きたいワン");
        builder.update(morphemes);
        WordClassBigram bigram = builder.build();

        Count word_class_count;
        word_class_count[11][5] = 1;  //名詞 -> 助詞
        word_class_count[5][9] = 1;   //助詞 -> 動詞
        word_class_count[9][6] = 1;   //動詞 -> 助動詞
        word_class_count[6][11] = 1;  //助動詞 -> 名詞

        assert(bigram.dump() == word_class_count);
    }

    WordClassBigram build() {
        return this.bigram;
    }
}
