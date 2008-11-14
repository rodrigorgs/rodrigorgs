#################### Compilando o relatório #####################

# dot autorizacao.dot -Tsvg | sed 's/10.00pt/10.00px/g'  | sed 's/Helvetica/Nimbus Sans L/g' > autorizacao.svg
#

SOURCEDOCUMENT=evolucao2008
DVIVIEWER=xdvi
PSVIEWER=gv
PDFVIEWER=xpdf -z page

CAPITULOS=$(wildcard *.tex)

GRAPHICS=

#######################################
#.SUFFIXES: .dia .eps
#
#.dia.eps:
#	dia --nosplash --export=$@ $<

all: $(SOURCEDOCUMENT).pdf

view: $(SOURCEDOCUMENT).pdf
	$(PDFVIEWER) $(SOURCEDOCUMENT).pdf &

$(SOURCEDOCUMENT).pdf: $(SOURCEDOCUMENT).tex $(CAPITULOS) $(SOURCEDOCUMENT).bib $(GRAPHICS) 
	pdflatex $< && \
	bibtex $(SOURCEDOCUMENT) && \
	pdflatex $< && \
	pdflatex $< || \
	$(RM) $@

graphics: $(GRAPHICS)

#$(FROM_SVG): %.pdf: %.svg
#	inkscape $< --export-eps=x.eps
#	epstopdf x.eps -o=$@
#	rm -f x.eps
#
#$(FROM_DOT): %.pdf: %.dot
#	dot -Gcharset=latin1 -Grankdir=LR -s300.0 -Tps $< > x.eps
#	epstopdf x.eps -o=$@ 

out:
	mkdir out

clean:
	$(RM) *.aux *.bbl *.blg *.lof *.lot *.log *.ps *.pdf *.dvi *~ *.toc $(GRAPHICS) profiling.xml

