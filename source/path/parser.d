module path.parser;
import path.mecab;

import std.string : toStringz;

import path.word_class : posidToClassIndex;


alias NODE = const(mecab_node_t)*;


class Morpheme {
    private const NODE node;

    this(NODE node) {
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
    private NODE bos_node;

    this(mecab_t* mecab, string sentence) {
        this.bos_node = mecab_sparse_tonode(mecab, sentence.toStringz);
    }

    /**
    Return an iterative array of Morphemes.
    */
    int opApply(int delegate(Morpheme) dg) {
        NODE node = bos_node;
        int result;

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
        SentenceParser parser = new SentenceParser();
        string[] words = ["スモモ", "も", "桃", "も", "桃", "の", "うち"];

        MorphemeList sentence = parser.parse("スモモも桃も桃のうち");
        auto i = 0;
        foreach(morpheme; sentence) {
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
