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
	private int current_map;

	/**
	 * Instantiantes the MainWindow view.
	 */
	public MainController (string? project_file = null) {
		Gtk.IconTheme.get_default().append_search_path ("../data/icons");
		Gtk.IconTheme.get_default().append_search_path ("data/icons");

		this.main_view = new MainWindow (this);
		this.maps = new GLib.HashTable<int, Map> (null, null);
		this.map_references = new GLib.HashTable<int, Gtk.TreeRowReference> (null, null);

		if(project_file != null)
			open_project_from_file (project_file);
	}

	/**
	 * Shows the main view. 
	 */
	public override void run () {
		this.main_view.show_all ();
	}

	/**
	 * Opens a project from file, loads its data and change the status of some widgets.
	 */
	public void open_project_from_file (string project_file) {
		File file = File.new_for_path (project_file);

		if(file.query_exists()) {
			this.project_filename = file.get_basename ();
			this.base_path = file.get_parent ().get_path () + "/";

			// Manages all the XML read stuff
			this.load_project_data ();
			this.load_maptree_data ();

			// Enable/disable some widgets
			this.main_view.set_project_status ("open");
			this.main_view.update_statusbar_current_frame();
		} else {
			warning("project file does not exist!");
		}
	}

	/**
	 * Opens a project from dialog, loads its data and change the status of some widgets.
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

		if (open_project_dialog.run () == Gtk.ResponseType.ACCEPT)
			open_project_from_file (open_project_dialog.get_filename ());

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
//		int current_map = int.parse (this.project_data.get_node_by_name ("current_map").content);

		// If the scale value found in the .rproject file is valid, set it.
		int current_scale = int.parse (this.project_data.get_node_by_name ("current_scale").content);
		if (current_scale > 0 && current_scale < 4) {
			this.main_view.set_current_scale ((Scale) current_scale);
		}

		// If the layer value found in the .rproject file is valid, set it.
		int current_layer = int.parse (this.project_data.get_node_by_name ("current_layer").content);
		if (current_layer > 0 && current_layer < 3) {
			this.main_view.set_current_layer ((LayerType) current_layer);
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

		this.current_map = 0;
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

		/* FIXME: this lines are for testing XmlWriter, remove after
		 * the writer is complete
		 */
/*
		var writer = new XmlWriter();
		print("Test XmlWriter:\n");
		print("--------Full Tree writing-------\n");
		writer.set_root(maptree);
		writer.write_file();
		writer.save_to_file(this.base_path + "data/maps/maptree2.xml");
		print("-----Use a subnode as root------\n");
		writer.set_root((((maptree.children).next).next).next);
		writer.write_file();
		writer.save_to_file(this.base_path + "data/maps/maptree3.xml");
*/	

		// Load "folder" and "map" icons before using them in the maptree treestore
		var folder_icon = Resources.load_icon_as_pixbuf (Resources.ICON_FOLDER, 16);
		var map_icon = Resources.load_icon_as_pixbuf (Resources.ICON_MAP, 16);

		/*
		 * The iter_table hashtable stores the last used TreeIters for each depth.
		 * They are used to point the correct parent when adding childs.
		 */
		var iter_table = new GLib.HashTable<int, Gtk.TreeIter?> (null, null);
		Gtk.TreeIter iter;
		int depth = 0;

		// Append and set the first row (game_title)
		maptree_model.append (out iter, null);
		maptree_model.set_value (iter, 0, 0);
		maptree_model.set_value (iter, 1, folder_icon);
		maptree_model.set_value (iter, 2, this.game_title);
		iter_table.set (depth, iter);

		// Append a new row, the next while block will set the data
		maptree_model.append (out iter, iter);

		// Get ready for the first map row
		XmlNode current_ref = maptree.children;
		depth++;

		// Every maptree row has a map_id, map_icon and map_name
		int map_id;
		string map_name;

		// This while block sets the map data and appends new rows to the maptree
		while (current_ref != null && depth > 0) {

			// attr_values[0] stores the map id
			map_id = int.parse (current_ref.attr_values[0]);

			/*
			 * If the map exists in the map_references table, let's check the next one
			 * or go back to its parent.
			 * 
			 * This allows to return to the correct map after adding child maps.
			 */
			if (this.map_references.get (map_id) != null) {
				if (current_ref.next != null) {
					maptree_model.append (out iter, iter_table.get (depth - 1));
					current_ref = current_ref.next;
				}
				else {
					current_ref = current_ref.parent;
					depth--;
				}
				continue;
			}

			// If the map file can be loaded, use its map_name instead of the maptree file one
			if (this.load_map_data (map_id) == true) {
				map_name = this.maps.get (map_id).name;
			}
			else {
				// TODO: create&load a blank map in order to ensure tree integrity
				map_name = current_ref.attr_values[1];
			}

			// Add map data to the row
			maptree_model.set_value (iter, 0, map_id);
			maptree_model.set_value (iter, 1, map_icon);
			maptree_model.set_value (iter, 2, map_name);

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
	 * Loads XML data from a map file.
	 *  
	 * @param The id of the map to load.
	 */
	public bool load_map_data (int map_id) {
		var parser = new XmlParser ();

		string map_filename = this.base_path + "data/maps/map" + map_id.to_string () + ".xml";

		// If the map file does not exists, there is nothing to do
		if (GLib.FileUtils.test (map_filename, GLib.FileTest.EXISTS) == false) {
			return false;
		}

		// Parse the xml file and load map data
		parser.parse_file (map_filename);
		XmlNode map_node = parser.get_root ();

		var map = new Map ();
		map.load_data (map_node);
		this.maps.set (map_id, map);

		return true;
	}

	/**
	 * Closes the current project and restores the default status of some widgets.
	 */
	public void close_project () {
		// Clear the main data
		this.game_title = null;
		this.project_filename = null;
		this.base_path = null;
		this.project_data = null;
		this.game_data = null;

		// Clear the vehicles data
		this.party = null;
		this.boat = null;
		this.ship = null;
		this.airship = null;

		// Empty the hashtables
		this.maps.remove_all ();
		this.map_references.remove_all ();

		// Empty the maptree TreeView
		this.main_view.treeview_maptree.clear ();
		this.current_map = 0;

		// Clear the tile palette and map DrawingAreas
		this.main_view.drawingarea_palette.clear ();
		this.main_view.drawingarea_maprender.clear ();

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
	 * Manages the reactions to the layer change.
	 */
	public void on_layer_change () {
		this.main_view.update_statusbar_current_frame();

		// Don't react if the current map is map 0 (game_title)
		if (this.current_map == 0) {
			return;
		}

		// Get the current layer
		var layer = (LayerType) this.main_view.get_current_layer ();

		// Update the palette
		var palette = this.main_view.drawingarea_palette;
		palette.set_layer (layer);

		// Update the maprender
		var maprender = this.main_view.drawingarea_maprender;
		maprender.set_layer (layer);
	}

	/**
	 * Manages the reactions to the scale change.
	 */
	public void on_scale_change () {
		// Don't react if the current map is map 0 (game_title)
		if (this.current_map == 0) {
			return;
		}

		// Get the current scale
		var scale = (Scale) this.main_view.get_current_scale ();

		// Update the maprender
		var maprender = this.main_view.drawingarea_maprender;
		maprender.set_scale (scale);
	}

	/**
	 * Manages the reactions to the map selection.
	 */
	public void on_map_selected (int map_id) {
		// Don't react if the selected map is map 0 (game_title) or the current map
		if (map_id == 0 || map_id == this.current_map) {
			return;
		}

		Map map = this.maps.get (map_id);

		this.current_map = map_id;

		var palette = this.main_view.drawingarea_palette;
		palette.clear ();
		palette.load_tileset (this.base_path + "graphics/tilesets/" + map.tileset);
		palette.set_layer (this.main_view.get_current_layer ());

		var maprender = this.main_view.drawingarea_maprender;
		maprender.clear ();
		maprender.load_map_scheme (map.lower_layer, map.upper_layer);
		maprender.set_layer (this.main_view.get_current_layer ());
		maprender.set_scale (this.main_view.get_current_scale ());
	}

	/**
	 * Manages the reactions to the map creation.
	 */
	public void on_map_properties (int map_id) {
		Map map = this.maps.get (map_id);

		var dialog = new MapPropertiesDialog (map);
		int result = dialog.run ();

		switch(result) {
			case Gtk.ResponseType.OK:
				/* TODO */
				warning ("TODO: update map properties of map %d", map_id);
				break;
			default:
				break;
		}

		dialog.destroy ();
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
		about_dialog.set_version (Resources.APP_VERSION);
		about_dialog.set_license_type (Gtk.License.GPL_3_0);
		about_dialog.set_program_name (Resources.APP_NAME);
		about_dialog.set_comments ("A role playing game editor");
		about_dialog.set_website (Resources.APP_WEBSITE);
		about_dialog.set_copyright ("© EasyRPG Project 2011");
		about_dialog.set_authors (Resources.APP_AUTHORS);
		about_dialog.set_artists (Resources.APP_ARTISTS);
		about_dialog.set_logo (Resources.load_icon_as_pixbuf ("easyrpg", 48));

		about_dialog.run ();
		about_dialog.destroy ();
	}
}

// Workaround
extern void gtk_file_filter_set_name (Gtk.FileFilter filter, string name);
