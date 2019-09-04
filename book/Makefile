all: book.tex
	pdflatex book
	makeindex book.idx
	pdflatex book
	mv book.pdf thinkstats2.pdf
	evince thinkstats2.pdf

DEST = /home/downey/public_html/greent/thinkstats2

distrib:
	rm -rf dist
	mkdir dist
	rsync -a thinkstats2.pdf html dist
	# rsync -a figs/*.fig figs/*.eps dist/tex/figs
	rsync -a dist/* $(DEST)
	chmod -R o+r $(DEST)/*
	cd $(DEST)/..; sh back

xxe:
	xmlcopyeditor ~/thinkstats/trunk/ThinkStats2/book/book/book.xml &

lint:
	xmllint -noout book/book.xml

%.png: %.pdf
	pdftoppm -png -singlefile $< $*
	pngquant --force --ext .png --skip-if-larger --quality 70-95 $@

# Use asciidoctor to generate HTML5
PNG_FILES := $(patsubst %.pdf,%.png,$(wildcard figs/*.pdf))

# Use pandoc to generate DocBook
book.xml: book.tex Makefile $(PNG_FILES)
	pandoc                \
		--standalone      \
		--from latex      \
		--to docbook5 	  \
		--mathml          \
		--output book.xml \
		book.tex
	perl -pi.orig -e 's{(<imagedata fileref="figs/\w+)\.pdf"}{\1.png"}' book.xml

# Convert footer into AsciiDoc that we can conditionaly include in the final document
advert.adoc: footer.html
	pandoc --from html --to asciidoctor --output advert.adoc footer.html

# Use pandoc to generate AsciiDoc.
# Current translation is not perfect so we need to add some filters and patches.
book.adoc: book.tex Makefile $(PNG_FILES)
	pandoc                 \
		--standalone       \
		--from latex       \
		--to asciidoctor   \
		--output book.adoc \
		book.tex
	@
	@## Search and replace to fix bugs and anomalies (TODO convert to LUA filters)
	@#> Fix image paths all images are inline (TODO: --default-image-extension=png)
	perl -pi -e 's{^image:(figs/\w+)\.pdf\[}{image::\1.png[}g;' book.adoc
	@#> Fix xrefs (TODO: maybe --reference-links)
	perl -pi \
	    -e 's{(Chapter|Section|Figure)\W{2}link:#(\w+)\[{1,2}[^]]+\]{1,2}}{<<\2>>}g;' \
	    book.adoc
	@
	@## Some changes are fundamental and cannot be filter/fix, so we patch
	@#> frontmatter (TODO convert to docinfo?, or --metadata-file=)
	@#> image blocks (TODO this could be a bug)
	@#> code blocks (not indicated in source. TODO try --listings option?)
	cp book.adoc book.adoc.orig
	patch book.adoc < book.adoc.patch

# The file new-book.adoc has manual edits that we plan to patch in later.
book.adoc.patch: book.adoc.orig new-book.adoc
	diff -u book.adoc.orig new-book.adoc > book.adoc.patch || true

# local copy of default style sheet
asciidoctor.css:
	echo 'text' | asciidoctor -o tmp.html -a linkcss -a copycss -
	rm -f tmp.html

book.html: book.adoc book.css asciidoctor.css $(PNG_FILES) Makefile
	asciidoctor \
		--doctype book                  \
		--attribute stylesheet=book.css \
		--out-file book.html book.adoc

new-book.html: new-book.adoc book.css asciidoctor.css $(PNG_FILES) Makefile
	asciidoctor \
		--doctype book                  \
		--attribute stylesheet=book.css \
		--out-file new-book.html new-book.adoc


FIGURES = figs/Correlation_examples.png

oreilly:
	rsync -a book/book.xml ~/oreilly/1234000002166
	rsync -a figs/*.pdf $(FIGURES) ~/oreilly/1234000002166/figs

clean:
	rm -f *~ *.aux *.log *.dvi *.idx *.ilg *.ind *.toc
