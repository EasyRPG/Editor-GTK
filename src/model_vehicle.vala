/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * model_vehicle.vala
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
 * Represents a vehicle object in the editor.
 */
public class Vehicle : Model {
	/*
	 * Properties
	 */
	public int image {get; set; default = 0;} // FIXME - Not int, just a temporary type
	public int map_id {get; set; default = 0;}

	/**
	 * Object X coordinate in tile units. Default is 0.
	 */
	public int x {get; set; default = 0;}

	/**
	 * Object Y coordinate in tile units. Default is 0
	 */
	public int y {get; set; default = 0;}

	/**
	 * The vehicle type
	 */
	private string type;

	/**
	 * Loads the vehicle data from an XmlNode object.
	 *
	 * @param data An XmlNode that contains the vehicle data.
	 */
	public override void load_data (XmlNode? data) {
		int map_id = 0;
		int x = 0;
		int y = 0;

		if (data != null) {
			type = data.name;
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
		}

		// Before this, there would be some value/type checking
		this.map_id = map_id;
		this.x = x;
		this.y = y;
	}

	/**
	 * Saves the vehicle data to an XmlNode object.
	 *
	 * @param data An XmlNode that contains the vehicle data.
	 */
	public override void save_data (out XmlNode data) {
		XmlNode node;
		data = new XmlNode(this.type);

		node = new XmlNode("map");
		node.content = this.map_id.to_string ();
		data.add_child(node);

		node = new XmlNode("x_coordinate");
		node.content = this.x.to_string ();
		data.add_child(node);

		node = new XmlNode("y_coordinate");
		node.content = this.y.to_string ();
		data.add_child(node);
	}
}
