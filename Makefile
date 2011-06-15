#
# Makefile for build my resume from some reStructuredText files.
# 
# Author: Rafael Goncalves Martins
# License: BSD (http://www.opensource.org/licenses/bsd-license.php)
#

LANGUAGES = en

SED = sed
RST2HTML = rst2html.py --generator --date --time --source-link \
	--cloak-email-addresses --link-stylesheet --initial-header-level=2
RST2PDF = rst2pdf

.PHONY: all
all: html pdf

resume-%.txt: resume-%.rst
	$(SED) \
		-e "s/NODEID/$(shell hg log -r . --template '{node|short}')/" \
		-e "s/DATE/$(shell hg log -r . --template '{date|shortdate}')/" \
		$< > $@

resume-%.html: resume-%.txt
	$(RST2HTML) \
		--language=$(shell echo $< | sed -e 's/resume-\([^.-]\+\)\.txt/\1/') \
		--stylesheet=style.css \
		$< $@

resume-%.pdf: resume-%.txt
	$(RST2PDF) \
		--language=$(shell echo $< | sed -e 's/resume-\([^.-]\+\)\.txt/\1/') \
		--output=$@ $<

.PHONY: txt
txt: $(addsuffix .txt, $(foreach lang, $(LANGUAGES), $(addsuffix $(lang), resume-)))

.PHONY: html
html: txt $(addsuffix .html, $(foreach lang, $(LANGUAGES), $(addsuffix $(lang), resume-)))

.PHONY: pdf
pdf: txt $(addsuffix .pdf, $(foreach lang, $(LANGUAGES), $(addsuffix $(lang), resume-)))

.PHONY: clean
clean:
	$(RM) -v *.txt *.html *.pdf

.PHONY: upload
upload: all
	ssh rafael@walrus.rafaelmartins.com -p 2234 "mkdir -p public_html/resume/"
	scp -P 2234 *.{txt,html,pdf,css} rafael@walrus.rafaelmartins.com:public_html/resume/

