include ../../../mk/pitchfork.mk

# Local variables
_NAME   = java
_EXEC   = $(shell ../../../bin/checkJava)

# Local works
do-install: $(PREFIX)/var/pkg/$(_NAME)
$(PREFIX)/var/pkg/$(_NAME):
	ln -sfn $(_EXEC) $(PREFIX)/bin/java
	echo bin/java > $@
