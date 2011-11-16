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
	private GLib.HashTable<int, Map> maps;
	private GLib.HashTable<int, Gtk.TreeRowReference> map_references;

	/**
	 * Instantiantes the MainWindow view.
	 */
	public MainController () {
		this.main_view = new MainWindow (this);
		this.maps = new GLib.HashTable<int, Map> (null, null);
		this.map_references = new GLib.HashTable<int, Gtk.TreeRowReference> (null, null);
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
			this.load_maptree_data ();
//			this.load_maps_data ();

			// Enable/disable some widgets
			this.main_view.set_project_status ("open");
			this.main_view.update_statusbar_current_frame();
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
		int current_map = int.parse (this.project_data.get_node_by_name ("current_map").content);

		// If the scale value found in the .rproject file is valid, set it.
		int current_scale = int.parse (this.project_data.get_node_by_name ("current_scale").content);
		if (current_scale > 0 && current_scale < 4) {
			this.main_view.set_current_scale (current_scale);
		}

		// If the layer value found in the .rproject file is valid, set it.
		int current_layer = int.parse (this.project_data.get_node_by_name ("current_layer").content);
		if (current_layer > 0 && current_layer < 3) {
			this.main_view.set_current_layer (current_layer);
		}

		// Load data from game.xml and instantiate the party and vehicles
		parser.parse_file (this.base_path + "data/game.xml");
		this.game_data = parser.get_root ();

		XmlNode title_node = this.game_data.get_node_by_name ("title");
		this.game_title = title_node.content;

		this.party = new Party ();
		XmlNode party_node = this.game_data.get_node_by_name ("party");
		this.party.load_data (party_node);

		this.boat = new Vehicle ();
		XmlNode boat_node = this.game_data.get_node_by_name ("boat");
		this.boat.load_data (boat_node);

		this.ship = new Vehicle ();
		XmlNode ship_node = this.game_data.get_node_by_name ("ship");
		this.ship.load_data (ship_node);

		this.airship = new Vehicle ();
		XmlNode airship_node = this.game_data.get_node_by_name ("airship");
		this.airship.load_data (airship_node);
	}

	/**
	 * Loads XML data from the maptree file.
	 */
	public void load_maptree_data () {
		var maptree_model = this.main_view.treeview_maptree.get_model () as MaptreeTreeStore;
		XmlParser parser = new XmlParser ();

		// Load data from the .rproject file
		parser.parse_file (this.base_path + "data/maps/maptree.xml");
		XmlNode maptree = parser.get_root ();

		/*
		 * The iter_table hashtable stores the last used TreeIters for each depth.
		 * They are used to point the correct parent when adding childs.
		 */
		var iter_table = new GLib.HashTable<int, Gtk.TreeIter?> (null, null);
		Gtk.TreeIter iter;

		// Append and set the first row (game_title)
		maptree_model.append (out iter, null);
		maptree_model.set_value (iter, 0, 0);
		maptree_model.set_value (iter, 1, this.main_view.treeview_maptree.pix_folder);
		maptree_model.set_value (iter, 2, this.game_title);
		iter_table.set (0, iter);

		// Append a new row, the next while block will set the data
		maptree_model.append (out iter, iter);
		iter_table.set (1, iter);

		XmlNode current_ref = maptree.children;
		int depth = 1;

		while (current_ref != null && depth > 0) {

			// attr_values[0] stores the map id
			int map_id = int.parse (current_ref.attr_values[0]);

			/*
			 * If the map exists in the map_references table, let's check the next one
			 * or go back to its parent.
			 * 
			 * This allows to return to the correct map after adding child maps.
			 */
			if (this.map_references.get (map_id) != null) {
				if (current_ref.next != null) {
					current_ref = current_ref.next;
				}
				else {
					current_ref = current_ref.parent;
					depth--;
				}
				continue;
			}

			// Add map data to the row
			maptree_model.set_value (iter, 0, int.parse (current_ref.attr_values[0]));
			maptree_model.set_value (iter, 1, this.main_view.treeview_maptree.pix_map);
			maptree_model.set_value (iter, 2, current_ref.attr_values[1]);

			// Mark the iter as the master iter for this depth
			iter_table.set (depth, iter);

			// A TreeRowReference is created and stored in map_references
			var path = new Gtk.TreePath.from_string (maptree_model.get_string_from_iter (iter_table.get (depth)));
			var row_reference = new Gtk.TreeRowReference (maptree_model, path);
			this.map_references.set (int.parse (current_ref.attr_values[0]), row_reference);

			// If this map has children, manage them
			if (current_ref.children != null) {
				maptree_model.append (out iter, iter_table.get (depth));
				current_ref = current_ref.children;
				depth++;
			}
			// No children? Next map
			else if (current_ref.next != null) {
				maptree_model.append (out iter, iter_table.get (depth - 1));
				current_ref = current_ref.next;
			}
			// Neither of them? Return to the parent
			else {
				current_ref = current_ref.parent;
				depth--;
			}
		}
	}

	/**
	 * Loads XML data from the map files.
	 */
	public void load_maps_data () {
		XmlParser parser = new XmlParser ();

		string maps_dir_name = this.base_path + "data/maps/";
		var maps_dir = File.new_for_path (maps_dir_name);

		try {
			var enumerator = maps_dir.enumerate_children ("standard::name", FileQueryInfoFlags.NONE);
			FileInfo file_info;
			string filename;

			while ((file_info = enumerator.next_file (null)) != null) {
				filename = file_info.get_name ();

				// Ignore files without ".xml" suffix
				if (!filename.has_suffix (".xml")) {
					continue;
				}

				string string_map_id = filename.replace ("map", "").replace (".xml", "");

				/*
				 * An non-int id will be parsed to 0:
				 *  "map23.xml" -> "23" -> 23
				 *  "mapzz.xml" -> "zz" -> 0
				 */
				int map_id = int.parse (string_map_id);

				// Maps with invalid map_id are ignored
				if (map_id < 1) {
					continue;
				}

				// Parse the xml file and load map data
				parser.parse_file (maps_dir_name + filename);
				XmlNode map_node = parser.get_root ();

				var map = new Map ();
				map.load_data (map_node);

				// Insert the map into the maps HashTable 
				this.maps.set (map_id, map);
			}
		}
		catch (Error e) {
			stderr.printf ("Error: %s\n", e.message);
		}
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

		// Hashtables are cleared
		this.maps.remove_all ();
		this.map_references.remove_all ();

		// The Maptree is cleared too
		this.main_view.treeview_maptree.clear ();

		// Enable/disable some widgets
		this.main_view.set_project_status ("closed");

		// Set default values for RadioActions and ToggleActions
		this.main_view.set_current_layer (LayerType.LOWER);
		this.main_view.set_current_scale (0);
		this.main_view.set_current_drawing_tool (DrawingTool.PEN);
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

	public void on_layer_change(){
		this.main_view.update_statusbar_current_frame();
	}
}

// Workaround
extern void gtk_file_filter_set_name (Gtk.FileFilter filter, string name);
