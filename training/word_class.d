/**
The definition of word classes.
*/
immutable wchar[][] WORD_CLASSES = [
    "その他",    //0
    "フィラー",  //1
    "感動詞",    //2
    "記号",      //3
    "形容詞",    //4
    "助詞",      //5
    "助動詞",    //6
    "接続詞",    //7
    "接頭詞",    //8
    "動詞",      //9
    "副詞",      //10
    "名詞",      //11
    "連体詞",    //12
];


immutable ulong N_CLASSES = WORD_CLASSES.length;


/**
Return the index of WORD_CLASSES corresponding posid.
*/
uint posidToClassIndex(ushort posid)
in {
    assert(0 <= posid && posid <= 68);
}
out(class_index) {
    assert(class_index < N_CLASSES);
}
body {
    uint class_index;
    //TODO add comments
    //TODO rewrite with BinarySearch
    if(posid == 0) {
        class_index = 0;
    } else if(posid == 1) {
        class_index = 1;
    } else if(posid == 2) {
        class_index = 2;
    } else if(3 <= posid && posid <= 9) {
        class_index = 3;
    } else if(10 <= posid && posid <= 12) {
        class_index = 4;
    } else if(13 <= posid && posid <= 24) {
        class_index = 5;
    } else if(posid == 25) {
        class_index = 6;
    } else if(posid == 26) {
        class_index = 7;
    } else if(27 <= posid && posid <= 30) {
        class_index = 8;
    } else if(31 <= posid && posid <= 33) {
        class_index = 9;
    } else if(34 <= posid && posid <= 35) {
        class_index = 10;
    } else if(36 <= posid && posid <= 67) {
        class_index = 11;
    } else if(posid == 68) {
        class_index = 12;
    }
    return class_index;
}
