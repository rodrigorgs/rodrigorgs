suffix=`date +%Y%m%d`

mkdir pages 2> /dev/null

wget 'http://wiki.gmf.ufcg.edu.br/index.php?title=Special%3APrefixindex&from=User%3ARodrigoRocha&namespace=0' --load-cookies cookies.txt --output-document=pages/pages.html

pages=`ruby list_pages.rb < pages/pages.html`

wget 'http://wiki.gmf.ufcg.edu.br/index.php/Special:Export' \
  --post-data "catname=&wpDownload=1&curonly=1&pages=$pages" \
  --output-document=pages/gmf-$suffix.xml --load-cookies cookies.txt

# separador: %0D%0A
