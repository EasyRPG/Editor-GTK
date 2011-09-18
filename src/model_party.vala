/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * party_model.vala
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

public class Party : Model {
	/*
	 * Properties
	 */
	// FIXME - Not int, just a temporary type
	public int characters {get; set; default = 0;}
	public int map_id {get; set; default = 0;}
	public int x {get; set; default = 0;}
	public int y {get; set; default = 0;}

	/*
	 * Constructor
	 */
	public Party () {

	}

	/*
	 * Load data
	 */
	public override void load_data (XmlNode data) {
		int map_id = 0;
		int x = 0;
		int y = 0;
		
		int i = 0;
		while(i < data.get_children_num ()) {
			switch (data.get_child(i).name) {
				case "map":
					map_id = int.parse (data.get_child(i).content);
					break;
				case "x_coordinate":
					x = int.parse (data.get_child(i).content);
					break;
				case "y_coordinate":
					y = int.parse (data.get_child(i).content);
					break;
				default:
					break;
			}
			i++;
		}

		// Before this, there would be some value/type checking
		this.map_id = map_id;
		this.x = x;
		this.y = y;
	}
}