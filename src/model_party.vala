/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * model_party.vala
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
 * Represents the party object in the editor. 
 */
public class Party : Model {
	/*
	 * Properties
	 */
	public int characters {get; set; default = 0;} // FIXME - Not int, just a temporary type
	public int map_id {get; set; default = 0;}

	/**
	 * Object X coordinate in tile units. Default is 0.
	 */
	public int x {get; set; default = 0;}

	/**
	 * Object Y coordinate in tile units. Default is 0.
	 */
	public int y {get; set; default = 0;}

	/**
	 * Loads the party data from an XmlNode object.
	 * 
	 * @param data An XmlNode that contains the party data.
	 */
	public override void load_data (XmlNode data) {
		int map_id = 0;
		int x = 0;
		int y = 0;

		XmlNode node = data.children;
		while (node != null) {
			switch (node.name) {
				case "map":
					map_id = int.parse (node.content);
					break;
				case "x_coordinate":
					x = int.parse (node.content);
					break;
				case "y_coordinate":
					y = int.parse (node.content);
					break;
				default:
					break;
			}
			node = node.next;
		}

		// Before this, there should be some value/type checking
		this.map_id = map_id;
		this.x = x;
		this.y = y;
	}
}