for f in sources/[0-9]*.md
do
  pandoc -V theme=white -t revealjs -o $(basename $f .md).html -s ${f} --slide-level 1 --template sources/default.revealjs
done
