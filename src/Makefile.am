## Process this file with automake to produce Makefile.in

## Created by Anjuta



AM_CPPFLAGS = \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" \
	$(EDITOR_CFLAGS)

AM_CFLAGS =\
	 -Wall\
	 -g

VALAFLAGS =  \
	--pkg gtk+-3.0 --vapidir . --pkg config

bin_PROGRAMS = editor

editor_SOURCES = \
	main_window.vala \
	editor.vala

editor_LDFLAGS = \
	-Wl,--export-dynamic

editor_LDADD = $(EDITOR_LIBS)

