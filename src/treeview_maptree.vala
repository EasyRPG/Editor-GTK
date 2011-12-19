/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * treeview_maptree.vala
 * Copyright (C) EasyRPG Project 2011
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
 * The maptree TreeView.
 */
public class MaptreeTreeView : Gtk.TreeView {
	private MaptreeTreeStore maptree_model;

	public signal void map_selected (int map_id);

	/**
	 * Builds the maptree TreeView.
	 */
	public MaptreeTreeView () {
		// The ID column can be added with the shorthand insert_column_with_attributes
		this.insert_column_with_attributes (-1, "ID", new Gtk.CellRendererText (), "text", 0);

		// The Map column contain two CellRenderers, so it must be built first
		var col_map = new Gtk.TreeViewColumn ();
		col_map.set_title ("Map");

		var cell_icon = new Gtk.CellRendererPixbuf ();
		var cell_name = new Gtk.CellRendererText ();
		
		col_map.pack_start (cell_icon, false);
		col_map.pack_start (cell_name, true);

		col_map.add_attribute (cell_icon, "pixbuf", 1);
		col_map.add_attribute (cell_name, "text", 2);

		this.append_column (col_map);

		// The map_id column should not be visible
		var col_map_id = this.get_column (0);
		col_map_id.set_visible (false);

		this.set_headers_visible (false);
		this.set_reorderable (true);

		// Get the TreeStore ready
		this.maptree_model = new MaptreeTreeStore (this);
		this.set_model (maptree_model);

		/*
		 * Connect signals
		 */
		this.cursor_changed.connect(on_change);
	}

	/**
	 * Clears the model.
	 */
	public void clear () {
		this.maptree_model.clear ();
	}

	/**
	 * This method is triggered everytime a row (map) is selected.
	 */
	public void on_change () {
		Gtk.TreeIter selected;

		// Don't try to load a map_id if there isn't any row selected (not probable but just in case)
		if (this.get_selection ().get_selected (null, out selected)) {
			var maptree_model = this.get_model ();

			GLib.Value value;
			maptree_model.get_value (selected, 0, out value);

			int map_id = value.get_int ();

			map_selected (map_id);
		}
	}
}
