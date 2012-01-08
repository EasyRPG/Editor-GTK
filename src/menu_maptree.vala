/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * treeview_maptree.vala
 * Copyright (C) EasyRPG Project 2012
 *
 * EasyRPG is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * EasyRPG is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * The maptree menu.
 */
public class MapTreeMenu : Gtk.Menu {

	/**
	 * Builds the maptree Menu for map nodes.
	 */
	public MapTreeMenu () {
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

		show_all ();
	}

	/**
	 * Builds the maptree Menu for project directory
	 */
	public MapTreeMenu.root () {
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
