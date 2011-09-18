/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * controller_main.vala
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

public class MainController : Controller {
	/*
	 * Properties
	 */
	// Views
	private MainWindow main_view;
	//private DatabaseDialog database_view;

	// Models
	private Party party;
	private Vehicle boat;
	private Vehicle ship;
	private Vehicle airship;

	// Others
	private string game_title {get; set; default = "";}
	private XmlNode project_data;

	/*
	 * Constructor
	 */
	public MainController () {
		this.main_view = new MainWindow (this);
		this.party = new Party ();
		this.boat = new Vehicle ();
		this.ship = new Vehicle ();
		this.airship = new Vehicle ();

		/*
		 * Parsing sample
		 */
		XmlParser parser = new XmlParser ();
		parser.parse_file ("./sample_game/data/project.xml");
		this.project_data = parser.root;

		XmlNode title_node = parser.get_node ("title");
		this.game_title = title_node.content;

		XmlNode party_node = parser.get_node ("party");
		this.party.load_data (party_node);

		XmlNode boat_node = parser.get_node ("boat");
		this.boat.load_data (boat_node);

		XmlNode ship_node = parser.get_node ("ship");
		this.ship.load_data (ship_node);

		XmlNode airship_node = parser.get_node ("airship");
		this.airship.load_data (airship_node);

		/*
		 * Testing XML data loading
		 */
		print ("Game title: %s\n\n", this.game_title);
		print ("Party data:\n");
		print ("  map_id: %u\n", this.party.map_id);
		print ("  x: %u\n", this.party.x);
		print ("  y: %u\n\n", this.party.y);
		print ("Boat data:\n");
		print ("  map_id: %u\n", this.boat.map_id);
		print ("  x: %u\n", this.boat.x);
		print ("  y: %u\n\n", this.boat.y);
		print ("Ship data:\n");
		print ("  map_id: %u\n", this.ship.map_id);
		print ("  x: %u\n", this.ship.x);
		print ("  y: %u\n\n", this.ship.y);
		print ("Airship data:\n");
		print ("  map_id: %u\n", this.airship.map_id);
		print ("  x: %u\n", this.airship.x);
		print ("  y: %u\n", this.airship.y);
	}

	/*
	 * Run
	 */
	public override void run () {
		this.main_view.show_all ();
	}

	public void show_database () {
		var database_dialog = new DatabaseDialog (this);
		database_dialog.run ();
		database_dialog.destroy ();
	}
}