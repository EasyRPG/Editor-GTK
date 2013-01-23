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
	abstract_imageset.vala \
	action.vala \
	controller.vala \
	database_dialog.vala \
	editor.vala \
	enum.vala \
	i_paint_tiles.vala \
	i_select_tiles.vala \
	main_window.vala \
	map_drawingarea.vala \
	map_edit_action.vala \
	map_properties_dialog.vala \
	map_shift_dialog.vala \
	maptree_menu.vala \
	maptree_treestore.vala \
	maptree_treeview.vala \
	model_map.vala \
	model_party.vala \
	model.vala \
	model_vehicle.vala \
	project_create_dialog.vala \
	resources.vala \
	rm2k_chipset_imageset.vala \
	rm2k_chipset_lower_imageset.vala \
	rm2k_chipset_upper_imageset.vala \
	stack.vala \
	structs.vala \
	tile_palette_drawingarea.vala \
	tiled_drawingarea.vala \
	tiled_map_drawingarea.vala \
	tileset.vala \
	utils.vala \
	view_actor.vala \
	view_generic_widgets.vala \
	xml_node.vala \
	xml_parser.vala \
	xml_writer.vala

easyrpg_editor_LDFLAGS = \
	-Wl,--export-dynamic

easyrpg_editor_LDADD = $(EASYRPG_EDITOR_LIBS)

