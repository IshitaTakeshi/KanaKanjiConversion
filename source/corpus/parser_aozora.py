import sys
import os
import codecs

from bs4 import BeautifulSoup




def extract_text_from_html(source_path):
    try:
        source_text = codecs.open(source_path, encoding='sjis').read()
    except UnicodeDecodeError as e:
        raise e

    soup = BeautifulSoup(source_text, "html.parser")

    #remove sentences which surrounded by tags below
    soup_ = soup('rt')
    soup_ += soup('rp')
    soup_ += soup('a')
    soup_ += soup('span')
    soup_ += soup('div', {"class": ['bibliographical_information',
                                    'notation_notes',
                                    'chitsuki_1']})

    for s in soup_:
        s.extract()

    return soup.get_text()


#returns the iterator of the paths to html files under the aozorabunko_dir
def html_paths(aozorabunko_dir):
    cards = os.path.join(aozorabunko_dir, 'cards')
    assert(os.path.exists(cards))

    for dirpath, dirnames, filenames in os.walk(cards):
        if not(os.path.basename(dirpath) == 'files'):
            continue

        for filename in filenames:
            _, ext = os.path.splitext(filename)
            if not(ext == '.html'):
                continue

            path = os.path.join(dirpath, filename)
            yield path


def generate_corpus(aozorabunko_dir, corpus_dir, enable_overwrite=False):
    def source_path_to_text_path(source_path):
        source_filename = os.path.basename(source_path)
        text_path = os.path.join(corpus_dir, source_filename)
        text_path, _ = os.path.splitext(text_path)
        text_path += '.txt'
        return text_path

    for source_path in html_paths(aozorabunko_dir):
        #rewrite the extension from html to txt
        text_path = source_path_to_text_path(source_path)

        if((not enable_overwrite) and os.path.exists(text_path)):
            continue

        try:
            print("analyzing {}".format(source_path))
            text = extract_text_from_html(source_path)
        except UnicodeDecodeError:
            continue

        print("saving as {}".format(text_path))
        open(text_path, 'w').write(text)



aozorabunko_dir = './aozorabunko'
corpus_dir = './corpus'

if(len(sys.argv) >= 2):
    aozorabunko_dir = sys.argv[1]

if not(os.path.exists(corpus_dir)):
    os.makedirs(corpus_dir)

generate_corpus(aozorabunko_dir, corpus_dir)
