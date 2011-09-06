## Process this file with automake to produce Makefile.in
## Created by Anjuta

SUBDIRS = src 

editordocdir = ${prefix}/doc/editor
editordoc_DATA = \
	README\
	COPYING\
	AUTHORS\
	ChangeLog\
	INSTALL\
	NEWS


EXTRA_DIST = $(editordoc_DATA)


# Remove doc directory on uninstall
uninstall-local:
	-rm -r $(editordocdir)
