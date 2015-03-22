import mecab;

import std.string : toStringz;

import word_class : posidToClassIndex;


alias NODE = const(mecab_node_t)*;


class Morpheme {
    private const NODE node;

    this(NODE node) {
        this.node = node;
    }

    @property string word() {
        import std.conv : to;
        auto length = this.node.length;
        return this.node.surface.to!string[0..length];
    }

    @property uint wordClassIndex() {
        return posidToClassIndex(node.posid);
    }
}


class MorphemeList {
    private NODE bos_node;

    this(mecab_t* mecab, string sentence) {
        this.bos_node = mecab_sparse_tonode(mecab, sentence.toStringz);
    }

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
        string words[] = ["スモモ", "も", "桃", "も", "桃", "の", "うち"];

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

    MorphemeList parse(string sentence) {
        return new MorphemeList(this.mecab, sentence);
    }
}
