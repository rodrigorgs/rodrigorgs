# dot autorizacao.dot -Tsvg | sed 's/10.00pt/10.00px/g'  | sed 's/Helvetica/Nimbus Sans L/g' > autorizacao.svg

SOURCEDOCUMENT=cloud
#PDFVIEWER=evince
PDFVIEWER=xpdf -remote rodrigo-xpdf

CAPITULOS=$(wildcard *.tex)

FROM_DOT=
FROM_SVG=
GRAPHICS=$(FROM_DOT) $(FROM_SVG)

all: $(SOURCEDOCUMENT).pdf

view: $(SOURCEDOCUMENT).pdf
	$(PDFVIEWER) $(SOURCEDOCUMENT).pdf &

fast: $(SOURCEDOCUMENT).tex $(CAPITULOS) $(SOURCEDOCUMENT).bib $(GRAPHICS) 
	pdflatex $<

$(SOURCEDOCUMENT).pdf: $(SOURCEDOCUMENT).tex $(CAPITULOS) $(SOURCEDOCUMENT).bib $(GRAPHICS) 
	pdflatex $< && \
	bibtex $(SOURCEDOCUMENT) && \
	pdflatex $< && \
	pdflatex $< || \
	$(RM) $@

graphics: $(GRAPHICS)

$(FROM_SVG): %.pdf: %.svg
	inkscape $< --export-eps=x.eps
	epstopdf x.eps -o=$@
	rm -f x.eps

$(FROM_DOT): %.pdf: %.dot
	dot -Gcharset=latin1 -Grankdir=LR -s300.0 -Tps $< > x.eps
	epstopdf x.eps -o=$@ 

clean:
	$(RM) *.aux *.bbl *.blg *.lof *.lot *.log *.ps *.pdf *.dvi *~ *.toc $(GRAPHICS) profiling.xml

