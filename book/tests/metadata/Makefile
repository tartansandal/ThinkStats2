run: example.tex Makefile
	pandoc                 \
		--standalone       \
		--from latex       \
		--to asciidoctor   \
		--metadata-file=metadata.yml \
		example.tex
