from glob import glob

for f in glob("*.csv"):
    text = open(f, encoding='eucjp').read()
    open(f, 'w').write(text)
