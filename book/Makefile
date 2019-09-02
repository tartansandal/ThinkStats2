#!/usr/bin/env lua
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

# Use pandoc to generate DocBook
book.xml: book.tex Makefile
	perl -pe 's/{\\tt ([^}]+)}/\\verb"\1"/g' book.tex | \
	pandoc                \
		--standalone      \
		--from latex      \
		--to docbook5 	  \
		--mathml          \
		--output - | \
	perl -pe 's{(<imagedata fileref="figs/\w+)\.pdf"}{\1.png"}' > book.xml

book2.adoc: book.xml Makefile
	pandoc                  \
		--standalone        \
		--from docbook      \
		--to asciidoctor    \
		--output book2.adoc \
		book.xml

# Use pandoc to generate AsciiDoc
new-book.adoc: book.tex Makefile
	pandoc                     \
		--standalone           \
		--from latex           \
		--to asciidoctor       \
		--output new-book.adoc \
		book.tex
	# FIXME write a lua filter to do this
	perl -pi -e 's{^image:(figs/\w+)\.pdf\[}{image::\1.png[}' \
			 -e 's{(Chapter|Section|Figure)\u00a0link:#(\w+)\[\[\w+\]\]}{<<\1>>}' \
			 new-book.adoc
	# patch in frontmatter and code block fixes
	patch new-book.adoc < book.adoc.patch

# Use asciidoctor to generate HTML5
PNG_FILES := $(patsubst %.pdf,%.png,$(wildcard figs/*.pdf))
book.html: book.adoc $(PNG_FILES)
	asciidoctor --doctype book --out-file book.html book.adoc


new-book.html: new-book.adoc $(PNG_FILES)
	asciidoctor --doctype book --out-file new-book.html new-book.adoc



FIGURES = figs/Correlation_examples.png

oreilly:
	rsync -a book/book.xml ~/oreilly/1234000002166
	rsync -a figs/*.pdf $(FIGURES) ~/oreilly/1234000002166/figs

clean:
	rm -f *~ *.aux *.log *.dvi *.idx *.ilg *.ind *.toc
