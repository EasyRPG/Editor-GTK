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

/**
 * Manages the database dialog and the main window views, and some project-related data
 * like the game title or the party and vehicle models.
 */
public class MainController : Controller {
	// Views
	private MainWindow main_view;

	// Models
	private Party party;
	private Vehicle boat;
	private Vehicle ship;
	private Vehicle airship;

	// Others
	private string game_title;
	private string base_path;
	private string project_filename;
	private XmlNode project_data;
	private XmlNode game_data;

	/**
	 * Instantiantes the MainWindow view.
	 */
	public MainController () {
		this.main_view = new MainWindow (this);
	}

	/**
	 * Shows the main view. 
	 */
	public override void run () {
		this.main_view.show_all ();
	}

	/**
	 * Opens a project, loads its data and change the status of some widgets. 
	 */
	public void open_project () {
		var open_project_dialog = new Gtk.FileChooserDialog ("Open Project", this.main_view,
		                                                     Gtk.FileChooserAction.OPEN,
		                                                     Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL,
		                                                     Gtk.Stock.OPEN, Gtk.ResponseType.ACCEPT);
		/*
		 * FIXME
		 * FileFilter.set_filter_name is not implemented yet but will work soon.
		 * More info: https://bugzilla.gnome.org/show_bug.cgi?id=647122
		 * 
		 * Using proposed workaround "gtk_file_filter_set_name".
		 */
		var file_filter = new Gtk.FileFilter();
		//file_filter.set_name ("EasyRPG Project (*.rproject)");
		//file_filter.set_filter_name ("EasyRPG Project (*.rproject)");
		gtk_file_filter_set_name (file_filter, "EasyRPG Project (*.rproject)");
		file_filter.add_pattern ("*.rproject"); // for case-insensitive patterns -> add_custom()
		open_project_dialog.add_filter (file_filter);
		
		if (open_project_dialog.run () == Gtk.ResponseType.ACCEPT) {
			// Get the base_path and project_filename from the selected file
			string full_path = open_project_dialog.get_filename ();
			string[] path_tokens = full_path.split ("/");
			this.project_filename = path_tokens[path_tokens.length - 1];
			this.base_path = full_path.replace (this.project_filename, "");
			
			// Manages all the XML read stuff
			this.load_project_data ();
			this.load_maps_data ();

			// Enable/disable some widgets
			this.main_view.set_project_status ("open");
		}
		open_project_dialog.destroy ();
	}

	/**
	 * Loads XML data from the .rproject and game.xml files.
	 */
	private void load_project_data () {
		XmlParser parser = new XmlParser ();
		
		// Load data from the .rproject file
		parser.parse_file (this.base_path + this.project_filename);
		this.project_data = parser.get_root ();
		int current_map = int.parse (parser.get_node ("current_map").content);
		int current_scale = int.parse (parser.get_node ("current_scale").content);
		int current_layer = int.parse (parser.get_node ("current_layer").content);
		if (current_scale > 0 && current_scale < 4) {
			this.main_view.set_current_scale (current_scale);
		}
		if (current_layer > 0 && current_layer < 3) {
			this.main_view.set_current_layer (current_layer);
		}
		this.main_view.update_statusbar_current_frame();

		// Load data from game.xml and instantiate the party and vehicles
		parser.parse_file (this.base_path + "data/game.xml");
		this.game_data = parser.get_root ();

		XmlNode title_node = parser.get_node ("title");
		this.game_title = title_node.content;

		this.party = new Party ();
		XmlNode party_node = parser.get_node ("party");
		this.party.load_data (party_node);

		this.boat = new Vehicle ();
		XmlNode boat_node = parser.get_node ("boat");
		this.boat.load_data (boat_node);

		this.ship = new Vehicle ();
		XmlNode ship_node = parser.get_node ("ship");
		this.ship.load_data (ship_node);

		this.airship = new Vehicle ();
		XmlNode airship_node = parser.get_node ("airship");
		this.airship.load_data (airship_node);

	}

	/**
	 * Loads XML data from the map files.
	 */
	public void load_maps_data () {
		XmlParser parser = new XmlParser ();

		/*
		 * Load example
		 * 
		 * The next goal is to load all the maps
		 */
		parser.parse_file (this.base_path + "data/maps/map1.xml");
		XmlNode map_node = parser.get_root ();
		
		Map test_map = new Map ();
		test_map.load_data (map_node);
	}

	/**
	 * Closes the current project and restores the default status of some widgets.
	 */
	public void close_project () {
		// Properties are set to null
		this.game_title = null;
		this.project_filename = null;
		this.base_path = null;
		this.project_data = null;
		this.game_data = null;

		this.party = null;
		this.boat = null;
		this.ship = null;
		this.airship = null;

		// Enable/disable some widgets
		this.main_view.set_project_status ("closed");

		// Set default values for RadioActions and ToggleActions
		this.main_view.set_current_layer (0);
		this.main_view.set_current_scale (0);
		this.main_view.set_current_drawing_tool (2);
		this.main_view.set_fullscreen_status (false);
		this.main_view.set_show_title_status (false);
		this.main_view.update_statusbar_current_frame();
	}

	/**
	 * Instantiates and shows the database dialog.
	 */
	public void show_database () {
		var database_dialog = new DatabaseDialog (this);
		database_dialog.run ();
		database_dialog.destroy ();
	}

	/**
	 * Instantiates and shows the about dialog.
	 */
	public void on_about () {
		var about_dialog = new Gtk.AboutDialog ();
		about_dialog.set_transient_for (this.main_view);
		about_dialog.set_modal (true);
		about_dialog.set_version ("0.1.0");
		about_dialog.set_license_type (Gtk.License.GPL_3_0);
		about_dialog.set_program_name ("EasyRPG Editor");
		about_dialog.set_comments ("A role playing game editor");
		about_dialog.set_website ("http://easy-rpg.org/");
		about_dialog.set_copyright ("© EasyRPG Project 2011");

		const string authors[] = {"Héctor Barreiro", "Glynn Clements", "Francisco de la Peña", "Aitor García", "Gabriel Kind", "Alejandro Marzini http://vgvgf.com.ar/", "Shin-NiL", "Rikku2000 http://u-ac.net/rikku2000/gamedev/", "Mariano Suligoy", "Paulo Vizcaíno", "Takeshi Watanabe http://takecheeze.blog47.fc2.com/", null};
		const string artists[] = {"Ben Beltran http://nsovocal.com/", "Juan «Magnífico»", "Marina Navarro http://muerteatartajo.blogspot.com/", null};
		about_dialog.set_authors (authors);
		about_dialog.set_artists (artists);

		try {
			var logo = new Gdk.Pixbuf.from_file ("./share/easyrpg/icons/hicolor/48x48/apps/easyrpg.png");
			about_dialog.set_logo (logo);
		}
		catch (Error e) {
			stderr.printf ("Could not load about dialog logo: %s\n", e.message);
		}

		about_dialog.run ();
		about_dialog.destroy ();
	}
	
	public void on_frame_change(){
		this.main_view.update_statusbar_current_frame();
	}

	enum Layer{
		LOWER,
		UPPER,
		EVENT
	}
	
	enum DrawingTool{
		SELECT,
		ZOOM,
		PEN,
		ERASER_NORMAL,
		ERASER_RECTANGLE,
		ERASER_CIRCLE,
		ERASER_FILL,
		RECTANGLE,
		CIRCLE,
		FILL
	}
	
}

// Workaround
extern void gtk_file_filter_set_name (Gtk.FileFilter filter, string name);
