module path.bigram;

import std.typecons : tuple, Tuple;
import std.conv : to;
import std.string : toStringz;
import core.exception : RangeError;

import path.parser : SentenceParser, MorphemeList, Morpheme;
import path.word_class : N_CLASSES, WORD_CLASSES;


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


/**
Class to keep a bigram.
*/
class WordClassBigram {
    private BIGRAM word_class_count;

    this() {
    }

    @property BIGRAM wordClassCount() {
        return this.word_class_count;
    }

    /**
    Merge another WordClassBigram to this.
    */
    void opOpAssign(string op)(WordClassBigram bigram) if(op == "~") {
        BIGRAM count = bigram.wordClassCount;
        foreach(int i, ref counts; this.word_class_count) {
            foreach(int j, ref e; counts) {
                e += count[i][j];
            }
        }
    }

    ///
    unittest {
        auto builder = new WordClassBigramBuilder();
        string sentence = "すもももももももものうち";
        WordClassBigram bigram1 = builder.parse(sentence);
        WordClassBigram bigram2 = builder.parse(sentence);

        BIGRAM word_class_count;
        word_class_count[11][5] = 6;
        word_class_count[5][11] = 6;

        bigram1 ~= bigram2;
        assert(bigram1.wordClassCount == word_class_count);
    }

    //TODO explain
    WordClassBigram opIndexUnary(string op)
                                (uint current_index, uint next_index)
                                if(op == "++") {
        this.word_class_count[current_index][next_index] += 1;
        return this;
    }

    ///
    unittest {
        auto bigram = new WordClassBigram();
        ++bigram[11, 5];
        ++bigram[5, 11];

        BIGRAM word_class_count;
        word_class_count[11][5] = 1;
        word_class_count[5][11] = 1;

        assert(bigram.wordClassCount == word_class_count);
    }

    override bool opEquals(Object o) {
        auto bigram = cast(WordClassBigram)o;
        return (this.wordClassCount == bigram.wordClassCount);
    }

    unittest {
        auto builder = new WordClassBigramBuilder();
        auto a = builder.parse("すもももももももものうち");
        auto b = builder.parse("すもももももももものうち");
        assert(a == b);

        auto c = builder.parse("この先生、きのこる");
        auto d = builder.parse("この先、生きのこる");
        assert(c != d);
    }

    override string toString() {
        import std.string : format;
        import std.array : replicate, join;

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

    void dump(string filename) {
        import std.stdio : File;
        import std.array : join;
        string arrayToLine(ulong[] array) {
            string[] line;
            foreach(ref e; array) {
                line ~= e.to!string;
            }
            return line.join(",");
        }

        auto file = File(filename, "w");
        foreach(array; this.wordClassCount) {
            file.writeln(arrayToLine(array));
        }
        file.close();
    }

    void load(string filename) {
        import std.stdio : File;
        import std.array : split, replace, array;
        //import std.string : split;
        import std.algorithm.iteration : map;

        auto file = File(filename, "r");

        auto i = 0;
        string line = file.readln().replace("\n", "");
        while(line !is null) {
            import std.stdio;
            auto a = array(map!(to!ulong)(line.split(",")));
            this.word_class_count[i][0..$] = a;

            i += 1;
            line = file.readln().replace("\n", "");
        }
    }

    unittest {
        auto builder = new WordClassBigramBuilder();
        auto bigram = new WordClassBigram();
        auto loader = new WordClassBigram();

        bigram ~= builder.parse("すもももももももものうち");
        bigram ~= builder.parse("この先生きのこる");

        import std.file : exists, remove;

        string filename = "test.csv";
        while(exists(filename)) {
            filename ~= ".test";
        }

        bigram.dump(filename);
        loader.load(filename);
        assert(bigram == loader);

        remove(filename);
    }
}


///
class WordClassBigramBuilder {
    this() {
    }

    /**
    Parse a sentence and returns a WordClassBigram object.
    */
    WordClassBigram parse(string sentence)
    body {
        import std.stdio;
        WordClassBigram bigram = new WordClassBigram();
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

            debug {
                import std.stdio;
                writefln("p: %2d  c: %2d  word: %s", p, c, morpheme.word);
            }

            ++bigram[p, c];
            previous = morpheme;
        }
        return bigram;
    }

    ///
    unittest {
        auto builder = new WordClassBigramBuilder();
        WordClassBigram bigram = builder.parse("すもももももももものうち");

        BIGRAM word_class_count;
        word_class_count[11][5] = 3;
        word_class_count[5][11] = 3;

        assert(bigram.wordClassCount == word_class_count);
    }

    unittest {
        auto builder = new WordClassBigramBuilder();
        WordClassBigram bigram = builder.parse("台湾に行きたいワン");

        BIGRAM word_class_count;
        word_class_count[11][5] = 1;  //名詞 -> 助詞
        word_class_count[5][9] = 1;   //助詞 -> 動詞
        word_class_count[9][6] = 1;   //動詞 -> 助動詞
        word_class_count[6][11] = 1;  //助動詞 -> 名詞

        assert(bigram.wordClassCount == word_class_count);
    }
}
