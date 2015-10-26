## Setting environment

### Installing MeCab

```
wget http://mecab.googlecode.com/files/mecab-0.996.tar.gz
tar xvf mecab-0.996.tar.gz
cd mecab-0.996
./configure --enable-utf8-only
make
sudo make install
```

### Installing the IPA dictionary

```
wget http://mecab.googlecode.com/files/mecab-ipadic-2.7.0-20070801.tar.gz
tar xvf mecab-ipadic-2.7.0-20070801.tar.gz
cd mecab-ipadic-2.7.0-20070801
./configure --with-charset=utf8
make
sudo make install
```
