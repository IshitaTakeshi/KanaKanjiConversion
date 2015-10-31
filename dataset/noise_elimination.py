import os
import re

# pip3 install progress
from progress.bar import Bar


def smooth(text):
    """Get rid the noise in the wikipedia corpus"""
    text = re.sub(r"=+(.*)=+", "", text)  # remove headers
    # if it is lists or items, regard their contents as sentenses
    # (append an extra comma to each)
    text = re.sub(r"(\*|\#|:|;)+(.*)\n", "\g<2>。\n", text)
    text = re.sub(r"\[(.*)\]", "", text)  # remove links, images, templates
    # remove all strings except multibyte characters
    text = re.sub(r"[\x01-\x7E]", "", text)
    text = re.sub(r"(。)+", "。\n", text)  # one sentense per one line
    return text


textdir = 'text'
outputdir = 'corpus'
os.mkdir(outputdir)

for dirpath, dirnames, filenames in os.walk(textdir):
    bar = Bar('Processing', max=len(filenames))
    for filename in filenames:
        src = os.path.join(dirpath, filename)
        text = open(src).read()
        text = smooth(text)

        dst = os.path.join(outputdir, filename)
        open(dst, "w").write(text)

        bar.next()
    bar.finish()
