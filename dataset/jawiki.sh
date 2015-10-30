url=https://dumps.wikimedia.org/jawiki/20151002/jawiki-20151002-pages-articles1.xml.bz2
textdir='text'

wget -c $url
wp2txt --input-file $(basename $url)
mkdir -p $textdir
mv jawiki*.txt $textdir
python3 noise_elimination.py
