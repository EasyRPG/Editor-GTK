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
	--pkg gtk+-3.0 --pkg libxml-2.0 --pkg gio-2.0 --vapidir . --pkg config

bin_PROGRAMS = editor

editor_SOURCES = \
	controller.vala \
	controller_main.vala \
	editor.vala \
	enum.vala \
	model.vala \
	model_layer.vala \
	model_map.vala \
	model_party.vala \
	model_vehicle.vala \
	utils.vala \
	view_actor.vala \
	view_generic_widgets.vala \
	view_database_dialog.vala \
	view_main_window.vala \
	widget_treeview_maptree.vala \
	xml_node.vala \
	xml_parser.vala

editor_LDFLAGS = \
	-Wl,--export-dynamic

editor_LDADD = $(EDITOR_LIBS)

