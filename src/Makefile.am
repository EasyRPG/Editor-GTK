## Process this file with automake to produce Makefile.in

## Created by Anjuta



AM_CPPFLAGS = \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	-DPACKAGE_SRC_DIR=\""$(srcdir)"\" \
	-DPACKAGE_DATA_DIR=\""$(datadir)"\" \
	$(EASYRPG_EDITOR_CFLAGS)

AM_CFLAGS =\
	 -Wall\
	 -Wno-unused-but-set-variable\
	 -g

VALAFLAGS =  \
	--pkg gtk+-3.0 --pkg gio-2.0 --vapidir . --pkg config

bin_PROGRAMS = easyrpg-editor

easyrpg_editor_SOURCES = \
	action_map_edit.vala \
	action_stack.vala \
	action.vala \
	controller.vala \
	drawingarea_map.vala \
	drawingarea_tile_palette.vala \
	editor.vala \
	edittool.vala \
	enum.vala \
	main_window.vala \
	menu_maptree.vala \
	model_map.vala \
	model_party.vala \
	model.vala \
	model_vehicle.vala \
	resources.vala \
	structs.vala \
	tool.vala \
	tools/eraser.vala \
	tools/pen.vala \
	tools/rectangle.vala \
	tools/zoom.vala \
	treestore_maptree.vala \
	treeview_maptree.vala \
	utils.vala \
	view_actor.vala \
	view_database_dialog.vala \
	view_generic_widgets.vala \
	view_map_properties_dialog.vala \
	view_map_shift_dialog.vala \
	view_project_create_dialog.vala \
	xml_node.vala \
	xml_parser.vala \
	xml_writer.vala

easyrpg_editor_LDFLAGS = \
	-Wl,--export-dynamic

easyrpg_editor_LDADD = $(EASYRPG_EDITOR_LIBS)

