/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * Copyright (C) 2012 EasyRPG Project
 *
 * License: https://github.com/EasyRPG/Editor/blob/master/COPYING GPL
 *
 * Authors:
 * - Sebastian Reichel (sre) <sre@ring0.de>
 */

/**
 * The maptree menu.
 */
public class MaptreeMenu : Gtk.Menu {
	/**
	 * Builds the maptree Menu for map nodes.
	 */
	public MaptreeMenu () {
		var item_prop = new Gtk.ImageMenuItem.from_stock (Gtk.Stock.PROPERTIES, null);
		item_prop.set_label ("Map Properties");
		item_prop.activate.connect(() => {map_properties ();});
		append (item_prop);

		var item_seperator1 = new Gtk.SeparatorMenuItem ();
		append (item_seperator1);

		var item_new_map = new Gtk.ImageMenuItem.from_stock (Gtk.Stock.NEW, null);
		item_new_map.set_label ("New Map");
		item_new_map.activate.connect(() => {map_new ();});
		append (item_new_map);

		var item_dungeon = new Gtk.ImageMenuItem.from_stock (Gtk.Stock.REFRESH, null);
		item_dungeon.set_label ("Generate Dungeon");
		item_dungeon.activate.connect(() => {map_dungeon ();});
		append (item_dungeon);

		var item_seperator2 = new Gtk.SeparatorMenuItem ();
		append (item_seperator2);

		var item_copy = new Gtk.ImageMenuItem.from_stock (Gtk.Stock.COPY, null);
		item_copy.set_label ("Copy Map");
		item_copy.activate.connect(() => {map_copy ();});
		append (item_copy);

		var item_paste = new Gtk.ImageMenuItem.from_stock (Gtk.Stock.PASTE, null);
		item_paste.set_label ("Paste Map");
		item_paste.activate.connect(() => {map_paste ();});
		append (item_paste);

		var item_delete = new Gtk.ImageMenuItem.from_stock (Gtk.Stock.DELETE, null);
		item_delete.set_label ("Delete Map");
		item_delete.activate.connect(() => {map_delete ();});
		append (item_delete);

		var item_seperator3 = new Gtk.SeparatorMenuItem ();
		append (item_seperator3);

		var item_shift = new Gtk.MenuItem.with_label ("Shift Map");
		item_shift.activate.connect(() => {map_shift ();});
		append (item_shift);

		/* show keybindings in menu */
		accel_group = new Gtk.AccelGroup();
		item_delete.add_accelerator ("activate", accel_group, Gdk.keyval_from_name("Delete"), 0, Gtk.AccelFlags.VISIBLE);
		item_copy.add_accelerator ("activate", accel_group, 'C', Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE);
		item_paste.add_accelerator ("activate", accel_group, 'V', Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE);

		/* no yet supported */
		item_dungeon.set_sensitive (false);
		item_copy.set_sensitive (false);
		item_paste.set_sensitive (false);

		show_all ();
	}

	/**
	 * Builds the maptree Menu for project directory
	 */
	public MaptreeMenu.root () {
		var item_new_map = new Gtk.ImageMenuItem.from_stock (Gtk.Stock.NEW, null);
		item_new_map.set_label ("New Map");
		item_new_map.activate.connect(() => {map_new ();});
		append (item_new_map);

		var item_seperator = new Gtk.SeparatorMenuItem ();
		append (item_seperator);

		var item_paste = new Gtk.ImageMenuItem.from_stock (Gtk.Stock.PASTE, null);
		item_paste.set_label ("Paste Map");
		item_paste.activate.connect(() => {map_paste ();});
		append (item_paste);

		/* show keybindings in menu */
		accel_group = new Gtk.AccelGroup();
		item_paste.add_accelerator ("activate", accel_group, 'V', Gdk.ModifierType.CONTROL_MASK, Gtk.AccelFlags.VISIBLE);

		/* no yet supported */
		item_paste.set_sensitive (false);

		show_all ();
	}

	public signal void map_new();
	public signal void map_dungeon();
	public signal void map_delete();
	public signal void map_copy();
	public signal void map_paste();
	public signal void map_properties();
	public signal void map_shift();
}
