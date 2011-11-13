/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * treestore_maptree.vala
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
 * The maptree TreeStore.
 */
public class MaptreeTreeStore : Gtk.TreeStore, Gtk.TreeDragSource, Gtk.TreeDragDest {

	/**
	 * Instantiates the Maptree TreeStore.
	 */
	public MaptreeTreeStore () {
		set_column_types(new GLib.Type[2] {
			typeof(int),
			typeof(string)
		});
	}

	/**
	 * Defines wheter the row is draggable.
	 */
	public bool row_draggable (Gtk.TreePath path) {
		// The game_title row (the only one with depth 1) should not be draggable 
		if (path.get_depth () == 1) {
			return false;
		}

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
		else if (dest_path.to_string () == "0:0") {
			return false;
		}

		return true;
	} 
}