/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * model_layer.vala
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
 * Represents a layer object in the editor. 
 */
public class Layer : Model {
	/**
	 * Array containing the tile id list.
	 * 
	 * Id 0 means no tile.
	 */
	public int[] tiles {get; set;}

	/**
	 * Loads the layer data from an XmlNode object.
	 * 
	 * @param data An XmlNode that contains the layer data.
	 */
	public override void load_data (XmlNode data) {
		string[] tiles_string = {};
		int[] tiles = {};

		XmlNode node = data.children;
		while (node != null) {
			switch (node.name) {
				case "tiles":
					tiles_string = node.content.split (" ");
					break;
				default:
					break;
			}
			node = node.next;
		}

		/*
		 * The tiles_string contains string elements that should be parsed to int
		 */
		int tile_id;
		foreach (string tile_string in tiles_string) {
			tile_id = int.parse (tile_string);

			// A good time to fix those tiles with negative id
			if (tile_id < 0) {
				tile_id = 0;
			}

			// Add the tile to the array
			tiles += tile_id;
		}
		this.tiles = tiles;
	}

	/**
	 * Prints the layer data.
	 */
	public void print_data () {
		print ("Tiles:\n");

		foreach (int tile_id in this.tiles) {
			print ("%s ", tile_id.to_string ());
		}

		print ("\n");
	}
}
