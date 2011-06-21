#
# Makefile for build my resume from some reStructuredText files.
# 
# Author: Rafael Goncalves Martins
# License: BSD (http://www.opensource.org/licenses/bsd-license.php)
#

LANGUAGES = en
FULL_LANGUAGES = en="English"

SED = sed
RST2HTML = rst2html.py --generator --date --time --cloak-email-addresses \
	--link-stylesheet --stylesheet=style.css --initial-header-level=2
RST2PDF = rst2pdf

PREFIXES = $(foreach lang, $(LANGUAGES), $(addsuffix $(lang), resume-))
TXT_TARGETS = $(addsuffix .txt, $(PREFIXES))
HTML_TARGETS = $(addsuffix .html, $(PREFIXES)) style.css
PDF_TARGETS = $(addsuffix .pdf, $(PREFIXES))

.PHONY: all
all: index.html

resume-%.txt: resume-%.rst
	$(SED) \
		-e "s/NODEID/$(shell hg log -r . --template '{node|short}')/" \
		-e "s/DATE/$(shell hg log -r . --template '{date|shortdate}')/" \
		$< > $@

resume-%.html: resume-%.txt
	$(RST2HTML) \
		--source-link \
		--language=$(shell echo $< | sed -e 's/resume-\([^.-]\+\)\.txt/\1/') \
		$< $@

resume-%.pdf: resume-%.txt
	$(RST2PDF) \
		--language=$(shell echo $< | sed -e 's/resume-\([^.-]\+\)\.txt/\1/') \
		--output=$@ $<

index.html: index.rst $(TXT_TARGETS) $(HTML_TARGETS) $(PDF_TARGETS)
	(cat index.rst; \
	echo ""; \
	echo "Files"; \
	echo "-----"; \
	echo ""; \
	for lang in $(FULL_LANGUAGES); do \
		echo -n "$${lang##*=} ("; \
		for filetype in txt html pdf; do \
			echo -n "\`$${filetype} <resume-$${lang%%=*}.$${filetype}>\`_"; \
			if [[ $${filetype} != pdf ]]; then \
				echo -n ", "; \
			else \
				echo ")"; \
			fi; \
		done; \
	done) | $(RST2HTML) \
		--report=3 --language=en > $@


.PHONY: txt
txt: $(TXT_TARGETS)

.PHONY: html
html: $(TXT_TARGETS) $(HTML_TARGETS)

.PHONY: pdf
pdf: $(TXT_TARGETS) $(PDF_TARGETS)

.PHONY: clean
clean:
	$(RM) -v *.txt *.html *.pdf

