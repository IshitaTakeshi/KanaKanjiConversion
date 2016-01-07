module dictionary.romaji_to_kana;

import std.ascii: isAlpha;
import std.stdio;
import std.file;
import std.string;
import dtrie: DTrie, KeyError;


string romaji_filename = "map/romaji.txt";
string hiragana_filename = "map/hiragana.txt";
string katakana_filename = "map/katakana.txt";


//romaji to kana
class RomajiKanaConverter {
    private DTrie!string romaji_hiragana_map;

    this() {
        string[] romaji = readText(romaji_filename).splitLines();
        string[] hiragana = readText(hiragana_filename).splitLines();

        assert(romaji.length == hiragana.length);
        this.romaji_hiragana_map = new DTrie!string(romaji, hiragana);
    }

    string convert(string romaji) {
        string kana;
        string query;
        string[] k;

        foreach(char c; romaji) {
            //must be within [A-z]
            if(!isAlpha(c)) {
                continue;
            }

            query ~= c;

            try {
                k = this.romaji_hiragana_map[query];
            } catch(KeyError e) {
                continue;
            }

            //append a hiragana character corresponding to the query
            kana ~= k[0];
            query = "";
        }
        return kana;
    }
}


unittest {
    auto converter = new RomajiKanaConverter();
    string katakana = converter.convert("orehaninngenngasukida");
    writeln("おれはにんげんがすきだ");
}
