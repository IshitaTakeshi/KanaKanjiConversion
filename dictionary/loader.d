import std.array : split, replace;
import std.algorithm.iteration : filter;
import std.typecons : tuple, Tuple;
import std.file : dirEntries, SpanMode;
import std.stdio : File;

import trie : Dictionary;


alias KEYVALUEPAIRS = Tuple!(string[], string[]);

struct DictionaryLoader {
    static KEYVALUEPAIRS loadKeyValuePairsFromFile(string filename) {
        auto file = File(filename, "r");

        string[] keys;
        string[] values;
        string line = file.readln();
        while(line !is null) {
            auto t = line.replace("\n", "").split("\t");

            keys ~= t[0];
            values ~= t[1];

            line = file.readln();
        }

        return tuple(keys, values);
    }

    /*
    Load key value pairs from files under datadir.

    Parameters:
    datadir : the path to a dictionary which dictionary files are in.
    */
    static KEYVALUEPAIRS loadKeyValuePairsFromFiles(string datadir) {
        string[] keys;
        string[] values;

        auto entries = dirEntries(datadir, SpanMode.breadth);
        auto filenames = filter!(`endsWith(a.name, ".dic")`)(entries);
        foreach(string filename; filenames) {
            auto t = loadKeyValuePairsFromFile(filename);
            keys ~= t[0];
            values ~= t[1];
        }
        return tuple(keys, values);
    }

    static Dictionary load(string dictionary_dir) {
        auto t = loadKeyValuePairsFromFiles(dictionary_dir);
        string[] keys = t[0];
        string[] values = t[1];
        return new Dictionary(keys, values);
    }
}


unittest {
    auto dictionary = DictionaryLoader.load("../data_mozc_test");
    assert(dictionary.get("あけます") ==
           ["あけます", "明けます", "空けます"]);
}
