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

# Use pandoc to generate AsciiDoc
book.adoc: book.tex Makefile $(PNG_FILES)
	pandoc                 \
		--standalone       \
		--from latex       \
		--to asciidoctor   \
		--output book.adoc \
		book.tex
	# Fix image paths and xrefs
	perl -pi \
		-e 's{^image:(figs/\w+)\.pdf\[}{image::\1.png[}g;' \
	    -e 's{(Chapter|Section|Figure)\W{2}link:#(\w+)\[{1,2}[^]]+\]{1,2}}{<<\2>>}g;' \
	    book.adoc
	cp book.adoc book.adoc.orig
	## Patch frontmatter, image blocks and code blocks
	patch book.adoc < book.adoc.patch

# new-book.adoc has manual edits that we may patch in later
# we create the patch manually rather than basing on a dependency
patch:
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
