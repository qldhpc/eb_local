include ../../../mk/pitchfork.mk

# Local variables
_NAME            = pip-8.1.2
_URL             = https://raw.githubusercontent.com/pypa/get-pip
_REV             = 430ba37776ae2ad89f794c7a43b90dc23bac334c
_WRKSRC          = $(WORKDIR)/$(_NAME)
_FILE            = get-pip.py

# Local works
do-fetch: | $(_FILE)
$(_FILE):
	$(PFHOME)/bin/pitchfork fetch --url $(_URL)/$(_REV)/$@
do-install: | $(PREFIX)/var/pkg/$(_NAME)
$(PREFIX)/var/pkg/$(_NAME): | do-fetch
	$(PREFIX)/bin/python $(_FILE) --no-setuptools
	$(PIP) install setuptools==33.1.1
	cd $(PREFIX) && \
        find bin/easy_install* \
             bin/pip* \
             bin/wheel \
             lib/python2.7/site-packages/easy_install* \
             lib/python2.7/site-packages/pip*          \
             lib/python2.7/site-packages/pkg_resources \
             lib/python2.7/site-packages/setuptools*   \
             lib/python2.7/site-packages/wheel* | sort -r > $@
	test -e lib/python2.7/site-packages/_markerlib && \
        find lib/python2.7/site-packages/_markerlib >> $@ || true
