/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * treestore_maptree.vala
 * Copyright (C) EasyRPG Project 2011-2012
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
 * The maptree TreeStore.
 */
public class MaptreeTreeStore : Gtk.TreeStore, Gtk.TreeDragSource, Gtk.TreeDragDest {

	/**
	 * A weak reference to the related MaptreeTreeView.
	 */
	private weak MaptreeTreeView maptree_treeview;

	/**
	 * The path of the last dragged row.
	 */
	private string dragged_row_path;

	/**
	 * This signal is emitted when a map path has changed.
	 *
	 * I.e: when a map has been moved through drag and drop.
	 */
	public signal void map_path_changed (int map_id, Gtk.TreePath iter);

	/**
	 * Instantiates the Maptree TreeStore.
	 */
	public MaptreeTreeStore (MaptreeTreeView treeview) {
		set_column_types(new GLib.Type[3] {
			typeof(int),
			typeof(Gdk.Pixbuf),
			typeof(string)
		});

		this.maptree_treeview = treeview;
	}

	/**
	 * Defines wheter the row is draggable.
	 */
	public bool row_draggable (Gtk.TreePath path) {
		// The game_title row (the only one with depth 1) should not be draggable
		if (path.get_depth () == 1) {
			return false;
		}

		this.dragged_row_path = path.to_string ();
		return true;
	}

	/**
	 * Defines wether a drop place is possible or not.
	 */
	public bool row_drop_possible (Gtk.TreePath dest_path, Gtk.SelectionData selection_data) {
		// The rows before and after the game_title row are not possible places
		if (dest_path.get_depth () == 1) {
			return false;
		}

		// The game_title row itself is not a possible place
		if (dest_path.to_string () == "0") {
			return false;
		}

		var source_path = new Gtk.TreePath.from_string (this.dragged_row_path);

		// A descendant of the dragged row is not a possible place
		if (dest_path.is_descendant (source_path)) {
			return false;
		}

		// The current place (after the previous row) should not appear as a possible place
		if (dest_path.compare (source_path) == 0) {
			return false;
		}

		// The current place (before the next row) should not appear as a possible place
		source_path.next ();
		if (dest_path.compare (source_path) == 0) {
			return false;
		}

		return true;
	}

	/**
	 * Manages the received data.
	 */
	public bool drag_data_received (Gtk.TreePath dest, Gtk.SelectionData selection_data) {
		// Chain with the parent drag_data_received
		if (base.drag_data_received (dest, selection_data)) {
			// The dragged map should be visible, so the parent must be expanded
			this.maptree_treeview.expand_to_path (dest);

			// Reselect the dragged map
			this.maptree_treeview.set_cursor (dest, this.maptree_treeview.get_column (1), false);

			// inform controller about the changes
			Gtk.TreeIter iter;
			this.get_iter (out iter, dest);
			map_position_update (iter);

			return true;
		}

		return false;
	}

	/**
	 * Send map_path_updated for iter and all of its children
	 */
	private void map_position_update (Gtk.TreeIter iter) {
		Gtk.TreeIter child;
		Value map_id;

		/* recursively remove all children */
		for(int i=0; i < this.iter_n_children (iter); i++)
			if(this.iter_nth_child (out child, iter, i))
				this.map_position_update(child);

		this.get_value (iter, 0, out map_id);

		// Emit the map_path_changed signal
		map_path_changed (map_id.get_int (), this.get_path (iter));
	}

	/**
	 * Removes Iter and all its children from the tree
	 * @return list of removed map ids
	 */
	public List<int> remove_all (Gtk.TreeIter iter) {
		var result = new List<int>();
		Gtk.TreeIter child;
		Value v;

		/* recursively remove all children */
		while(this.iter_children(out child, iter))
			result.concat(this.remove_all(child));

		/* remove ourselves */
		this.get_value (iter, 0, out v);
		result.append(v.get_int());
		this.remove(iter);

		return result;
	}
}
