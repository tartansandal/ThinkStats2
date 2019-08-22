
all:
	pdflatex book
	makeindex book.idx
	pdflatex book
	mv book.pdf thinkstats2.pdf

hevea:
	sed 's/\(figs\/[^.]*\).\(pdf\|png\)/\1.eps/' book.tex > thinkstats2.tex
	rm -rf html
	mkdir html
	hevea -O -e latexonly htmlonly thinkstats2
# the following greps are a kludge to prevent imagen from seeing
# the definitions in latexonly, and to avoid headers on the images
	grep -v latexonly thinkstats2.image.tex > a; mv a thinkstats2.image.tex
	sed s/\\\\usepackage{fancyhdr}// < thinkstats2.image.tex > a; mv a thinkstats2.image.tex
	imagen -png thinkstats2
	hacha thinkstats2.html
	cp up.png next.png back.png html
	mv index.html thinkstats2.css thinkstats2*.html thinkstats2*.png *motif.gif html

DEST = /home/downey/public_html/greent/thinkstats2

distrib:
	rm -rf dist
	mkdir dist
	rsync -a thinkstats2.pdf html dist
	# rsync -a figs/*.fig figs/*.eps dist/tex/figs
	rsync -a dist/* $(DEST)
	chmod -R o+r $(DEST)/*
	cd $(DEST)/..; sh back

plastex:
	# Before running plastex, we need the current directory in PYTHONPATH
	# export PYTHONPATH=$PYTHONPATH:.
	rm -rf /home/downey/thinkstats/trunk/book/.svn
	plastex --renderer=DocBook --theme=book --image-resolution=300 --filename=book.xml book.tex
	rm -rf /home/downey/thinkstats/trunk/book/.svn

xxe:
	xmlcopyeditor ~/thinkstats/trunk/ThinkStats2/book/book/book.xml &

lint:
	xmllint -noout book/book.xml

vector:
	plastex --renderer=DocBook --theme=book --vector-imager=dvisvgm --filename=book.xml book.tex

small: small.tex
	plastex --renderer=DocBook --theme=book --image-resolution=300 --filename=small.xml small.tex

sample:
	plastex --renderer=DocBook --theme=book --image-resolution=300 --image-scale-factor=0.25 --filename=sample2e.xml sample2e.tex
	~/Downloads/xxe-perso-4_8_0/bin/xxe sample2e/sample2e.xml

FIGURES = figs/Correlation_examples.png

oreilly:
	rsync -a book/book.xml ~/oreilly/1234000002166
	rsync -a figs/*.pdf $(FIGURES) ~/oreilly/1234000002166/figs

clean:
	rm -f *~ *.aux *.log *.dvi *.idx *.ilg *.ind *.toc

.PHONY: clean oreilly sample small lint xxe plastex distrib hevea all

## Rules for building HTML with `lwarp` ##

# # Dont need this since pdfs are already part of the project
# Make PDF files from EPS files with 'epstopdf'
#%.pdf: %.eps
#	lwarpmk epstopdf $<
#	# generates files in same dir as source, so no need to move

# Make SVG files from PDF files with 'pdftosvg'
%.svg: %.pdf
	lwarpmk pdftosvg $<
	# generates files in current dir, so move into figs
	mv $(notdir $@) figs/

#
# We use chains of sentinels (.lwarp_* files) to ensure the correct ordering of
# operations while avoiding unnessary tasks.
#

# Generate PDF from source to configure lwarp
# Note: `lwarpmk print1` regenerates book.pdf, so we cant use that file as a sentinel
.lwarp_source: book.tex
	rm -f .lwarp_source
	pdflatex book
	makeindex book.idx
	pdflatex book
	touch .lwarp_source

# Re-generate PDF from source with lwarp configured
.lwarp_print: .lwarp_source
	rm -f .lwarp_print
	lwarpmk print1; \
	while grep -q 'Rerun to get cross-references right' book.log; \
	do \
		lwarpmk print1; \
	done;
	touch .lwarp_print
	touch -r .lwarp_source book.tex

# HTML requires an SVG file for each EPS file in figs directory
SVG_FILES := $(patsubst %.eps,%.svg,$(wildcard figs/*.eps))

# Generate HTML from the PDF
.lwarp_html: .lwarp_print $(SVG_FILES) book_mathjax.html
	rm -f .lwarp_html
	lwarpmk html1; \
	while grep -q 'Rerun to get cross-references right' book_html.log; \
	do \
		lwarpmk html1; \
	done;
	touch .lwarp_html
	touch -r .lwarp_source book.tex

# Generate SVG images of math from the HTML
.lwarp_images: .lwarp_html
	rm -f .lwarp_images
	lwarpmk limages
	lwarpmk html1
	touch .lwarp_images
	touch -r .lwarp_source book.tex

# Generate PDF and HTML indexes
.lwarp_index: .lwarp_html
	rm -f .lwarp_index
	lwarpmk printindex
	lwarpmk htmlindex
	touch .lwarp_index
	touch -r .lwarp_source book.tex

# Build HTML using SVG images to display math
lwarp: .lwarp_images .lwarp_index
	rm -rf html
	mkdir html
	mkdir html/figs
	cp figs/*.svg html/figs/
	cp -a book-images html/
	cp lwarp*.css book.css html/
	cp index.html right.html node-*.html html/

# Build HTML using MathJax to display math
# XXX uncomment the 'mathjax' option to the 'lwarp' package in book.tex first
lwarp-mathjax: .lwarp_index
	rm -rf html-mathjax
	mkdir html-mathjax
	mkdir html-mathjax/figs
	cp figs/*.svg html-mathjax/figs/
	cp lwarp*.css book.css html-mathjax/
	cp index.html right.html book_mathjax.html node-*.html html-mathjax/

lwarp-clean: clean
	rm -f .lwarp_* book_html.html index.html node-*.html
	rm -rf book-images html

.PHONY: lwarp lwarp-mathjax lwarp-clean
