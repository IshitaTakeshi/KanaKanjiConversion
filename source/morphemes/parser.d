module morphemes.parser;

import std.stdio;
import std.string : toStringz;

import morphemes.mecab;
import morphemes.word_class : posidToClassIndex;


alias Node = const(mecab_node_t)*;


class Morpheme {
    private const Node node;

    this(Node node) {
        this.node = node;
    }

    /**
    Return a word of a corresponding morpheme.
    */
    @property string word() {
        import std.conv : to;
        auto length = this.node.length;
        return this.node.surface.to!string[0..length];
    }

    /**
    Return an index of word_class.WORD_CLASSES.
    */
    @property uint wordClassIndex() {
        return posidToClassIndex(node.posid);
    }
}


class MorphemeList {
    private Node bos_node;

    this(mecab_t* mecab, string sentence) {
        this.bos_node = mecab_sparse_tonode(mecab, sentence.toStringz);
    }

    /**
    Return an iterative array of Morphemes.
    */
    int opApply(int delegate(Morpheme) dg) {
        int result;
        Node node = this.bos_node;

        //iterate from next of BOS until second to EOS
        node = node.next;
        for(; node.stat != MECAB_EOS_NODE; node = node.next) {
            result = dg(new Morpheme(node));

            if(result != 0) {
                break;
            }
        }
        return result;
    }

    ///
    unittest {
        // nothing should happen even if parsing empty string
        SentenceParser parser = new SentenceParser();
        MorphemeList morphemes = parser.parse("");
        morphemes.toWords();
    }

    ///
    unittest {
        SentenceParser parser = new SentenceParser();
        string[] words = ["スモモ", "も", "桃", "も", "桃", "の", "うち"];

        MorphemeList morphemes = parser.parse("スモモも桃も桃のうち");
        auto i = 0;
        foreach(morpheme; morphemes) {
            assert(words[i] == morpheme.word);
            i += 1;
        }
    }
}


class SentenceParser {
    private mecab_t* mecab;

    this() {
        this.mecab = mecab_new2("");
    }

    ~this() {
        mecab_destroy(this.mecab);
    }

    /**
    Analyze a sentence and return the result as a MorphemeList object.
    */
    MorphemeList parse(string sentence) {
        return new MorphemeList(this.mecab, sentence);
    }
}


string[] toWords(MorphemeList morphemes) {
    string[] words;

    foreach(morpheme; morphemes) {
        words ~= morpheme.word;
    }
    return words;
}


unittest {
    string sentence = "すもももももももものうち";
    MorphemeList morphemes = new SentenceParser().parse(sentence);
    string[] words = morphemes.toWords();
    string[] result = ["すもも", "も", "もも", "も", "もも", "の", "うち"];
    assert(words == result);
}
