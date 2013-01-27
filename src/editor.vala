/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * Copyright (C) 2011-2012 EasyRPG Project
 *
 * License: https://github.com/EasyRPG/Editor/blob/master/COPYING GPL
 *
 * Authors:
 * - Mariano Suligoy (MarianoGNU) <marianognu.easyrpg@gmail.com>
 * - Aitor García (Falc) <aitor.falc@gmail.com>
 * - Sebastian Reichel (sre) <sre@ring0.de>
 */

/**
 * Editor is the application class, the starting point for the app.
 */
public class Editor {
	// MainWindow instance
	private MainWindow main_window;

	// Project main info
	private string game_title;
	private string base_path;
	private string project_filename;
	private XmlNode project_data;
	private XmlNode game_data;
	private string[] tilesets;
	private int current_map_id;

	// Map related structures
	private GLib.HashTable<int, Map> maps;
	private GLib.HashTable<int, UndoManager.Stack> map_changes;
	private GLib.HashTable<int, Gtk.TreeRowReference> map_references;

	// Models
	private Party party;
	private Vehicle boat;
	private Vehicle ship;
	private Vehicle airship;

	// Static
	static string[] files;
	static bool opt_version;

	// Const
	const OptionEntry[] option_entries = {
		{ "version", 'v', OptionFlags.IN_MAIN, OptionArg.NONE, ref opt_version, "output version information and exit", null },
		{ "", 0, 0, OptionArg.FILENAME_ARRAY, ref files, "input project file", "FILE" },
		{null}
	};

	/**
	 * Editor constructor.
	 */
	public Editor () {
		// Append icon paths
		Gtk.IconTheme.get_default().append_search_path ("../data/icons");
		Gtk.IconTheme.get_default().append_search_path ("data/icons");

		// Instance the main window
		this.main_window = new MainWindow (this);

		// Instance the map related structures
		this.maps = new GLib.HashTable<int, Map> (null, null);
		this.map_references = new GLib.HashTable<int, Gtk.TreeRowReference> (null, null);
		this.map_changes = new GLib.HashTable<int, UndoManager.Stack> (null, null);

		// Connect the map reorder signal from treeview_maptree
		this.main_window.treeview_maptree.map_reordered.connect(this.on_map_reordered);
	}

	/**
	 * Run!
	 */
	public void run () {
		// Show the main window
		this.main_window.show_all ();

		// If a project_file was specified, open the project
		string project_file = (this.files != null) ? files[0] : null;
		if(project_file != null) {
			this.open_project (project_file);
		}
	}

	/**
	 * Returns the current map id.
	 */
	public int get_current_map_id () {
		return this.current_map_id;
	}

	/**
	 * Returns the tileset list.
	 */
	public string[] get_tilesets () {
		return this.tilesets;
	}

	/**
	 * Opens a project, loads its data and change the status of some widgets.
	 */
	public void open_project (string project_file) {
		File file = File.new_for_path (project_file);

		try {
			// Get the project filename and base path
			this.project_filename = file.get_basename ();
			this.base_path = file.get_parent ().get_path () + "/";

			// Load all the required XML data
			this.load_project_data ();
			this.load_maptree_data ();

			// Enable/disable some widgets
			this.main_window.set_project_status ("open");
			this.update_undo_redo_buttons ();
			this.main_window.update_statusbar_current_frame();
		}
		catch (Error e) {
			// Show an error dialog
			var error_dialog = new Gtk.MessageDialog (
				this.main_window,
				Gtk.DialogFlags.MODAL|Gtk.DialogFlags.DESTROY_WITH_PARENT,
				Gtk.MessageType.ERROR, Gtk.ButtonsType.OK,
				e.message
			);

			error_dialog.run ();
			error_dialog.destroy ();
		}
	}

	/**
	 * Opens a project from dialog, loads its data and change the status of some widgets.
	 */
	public void open_project_from_dialog () {
		var open_project_dialog = new Gtk.FileChooserDialog (
			"Open Project", this.main_window,
			Gtk.FileChooserAction.OPEN,
			Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL,
			Gtk.Stock.OPEN, Gtk.ResponseType.ACCEPT
		);

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
			this.open_project (open_project_dialog.get_filename ());
		}

		open_project_dialog.destroy ();
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

		// Clear the models
		this.party = null;
		this.boat = null;
		this.ship = null;
		this.airship = null;

		// Close current map
		this.close_map ();

		// Empty the hashtables
		this.maps.remove_all ();
		this.map_changes.remove_all ();
		this.map_references.remove_all ();

		// Empty the maptree TreeView
		this.main_window.treeview_maptree.clear ();
		this.current_map_id = 0;

		// Enable/disable some widgets
		this.main_window.set_project_status ("closed");

		// Set default values for RadioActions and ToggleActions
		this.main_window.set_current_layer (LayerType.LOWER);
		this.main_window.set_current_scale (0);
		this.main_window.set_current_drawing_tool (DrawingTool.PEN);
		this.main_window.set_fullscreen_status (false);
		this.main_window.set_show_title_status (false);
		this.main_window.update_statusbar_current_frame ();
	}

	/**
	 * Reloads the project.
	 */
	public void reload_project () {
		this.close_project ();

		var file = this.base_path + this.project_filename;
		this.open_project (file);
	}

	/**
	 * Loads XML data from the .rproject and game.xml files.
	 */
	private void load_project_data () throws Error {
		XmlParser parser = new XmlParser ();

		// Load data from the .rproject file
		parser.parse_file (this.base_path + this.project_filename);
		this.project_data = parser.get_root ();

//		int current_map_id = int.parse (this.project_data.get_node_by_name ("current_map").content);
		this.current_map_id = 0;

		// If the scale value found in the .rproject file is valid, set it.
		int current_scale = int.parse (this.project_data.get_node_by_name ("current_scale").content);
		if (current_scale > 0 && current_scale < 4) {
			this.main_window.set_current_scale ((Scale) current_scale);
		}

		// If the layer value found in the .rproject file is valid, set it.
		int current_layer = int.parse (this.project_data.get_node_by_name ("current_layer").content);
		if (current_layer > 0 && current_layer < 3) {
			this.main_window.set_current_layer ((LayerType) current_layer);
		}

		// Load data from game.xml
		parser.parse_file (this.base_path + "data/game.xml");
		this.game_data = parser.get_root ();

		XmlNode title_node = this.game_data.get_node_by_name ("title");
		this.game_title = title_node.content;

		// Instantiate the party and vehicles
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

		/*
		 * Load tilesets from "graphics/tilesets"
		 * TODO: This should be changed when the database load process is completed
		 */
		try {
			var dir = Dir.open (this.base_path + "graphics/tilesets", 0);
			string entry;
			while ((entry = dir.read_name ()) != null) {
				this.tilesets += entry;
			}
		}
		catch (FileError e) {
			if (e is FileError.NOENT) {
				; /* Directory may not exist in new, empty projects. */
			}
			else {
				error ("Could not open tileset directory: %s", e.message);
			}
		}

		/* TODO: sort tilesets alphabetically */
	}

	/**
	 * Writes project data to the .rproject file.
	 */
	private void save_project_data () throws Error {
		XmlNode root, node;
		string rproject_file = this.base_path + this.project_filename;
		var writer = new XmlWriter ();

		// Root element
		root = new XmlNode ("project");

		// Current map
		node = new XmlNode ("current_map");
		node.content = this.current_map_id.to_string ();
		root.add_child (node);

		// Current layer
		node = new XmlNode ("current_layer");
		node.content = this.main_window.get_current_layer ().to_int ().to_string ();
		root.add_child (node);

		// Current map
		node = new XmlNode ("current_scale");
		node.content = this.main_window.get_current_scale ().to_int ().to_string ();
		root.add_child (node);

		writer.set_root (root);
		writer.generate ();
		writer.write (rproject_file);
	}

	/**
	 * Writes game data to the game.xml file.
	 */
	private void save_game_data () throws Error {
		XmlNode root, node;
		string game_file = this.base_path + "data/game.xml";
		var writer = new XmlWriter ();

		// Root element
		root = new XmlNode ("game");

		// Game title
		node = new XmlNode ("title");
		node.content = this.game_title;
		root.add_child (node);

		// Vehicles
		this.party.save_data(out node);
		root.add_child (node);

		this.boat.save_data(out node);
		root.add_child (node);

		this.ship.save_data(out node);
		root.add_child (node);

		this.airship.save_data(out node);
		root.add_child (node);

		writer.set_root (root);
		writer.generate ();
		writer.write (game_file);
	}

	/**
	 * Loads XML data from the maptree file.
	 */
	public void load_maptree_data () throws Error {
		XmlNode maptree;

		string maptreefile = this.base_path + "data/maps/maptree.xml";
		var maptree_model = this.main_window.treeview_maptree.get_model () as MaptreeTreeStore;
		XmlParser parser = new XmlParser ();

		// Load icons for maptree treestore
		var folder_icon = Resources.load_icon_as_pixbuf (Gtk.Stock.DIRECTORY, 16);
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

		// We are done if maptree file does not exist (=> new, empty project)
		if(!FileUtils.test (maptreefile, FileTest.IS_REGULAR)) {
			return;
		}

		// Load data from the .rproject file
		parser.parse_file (maptreefile);
		maptree = parser.get_root ();

#if 0
		/* FIXME: this lines are for testing XmlWriter, remove after
		   the writer is complete */

		var writer = new XmlWriter();
		print("Test XmlWriter:\n");
		print("--------Full Tree writing-------\n");
		writer.set_root(maptree);
		writer.generate();
		writer.save_to_file(this.base_path + "data/maps/maptree2.xml");
		print("-----Use a subnode as root------\n");
		writer.set_root((((maptree.children).next).next).next);
		writer.generate();
		writer.save_to_file(this.base_path + "data/maps/maptree3.xml");
#endif

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
			map_id = int.parse (current_ref.attributes["id"]);

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
				map_name = current_ref.attributes["name"];
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
			this.map_references.set (int.parse (current_ref.attributes["id"]), row_reference);

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

		/* expand root element */
		this.main_window.treeview_maptree.expand_to_path (new Gtk.TreePath.from_string ("0"));
	}

	/**
	 * Builds an updated maptree file.
	 */
	public void save_maptree_data () throws Error {
		var root = new XmlNode ("maptree");
		var parent = root;
		var writer = new XmlWriter ();
		string maps_path = this.base_path + "data/maps/";
		var maptree_model = this.main_window.treeview_maptree.get_model () as MaptreeTreeStore;
		Gtk.TreeIter tmp, iter;
		bool exit = false;
		Value maptree_val;

		maptree_model.get_iter_first (out iter);
		if(maptree_model.iter_children (out iter, iter)) {
			while (!exit) {
				// Create a node and add it
				var node = new XmlNode ("map");

				maptree_model.get_value (iter, 0, out maptree_val);
				node.attributes["id"] = maptree_val.get_int ().to_string ();

				maptree_model.get_value (iter, 2, out maptree_val);
				node.attributes["name"] = maptree_val.get_string ();

				parent.add_child(node);

				// Process children
				if (maptree_model.iter_children (out tmp, iter)) {
					iter = tmp;
					parent = node;
					continue;
				}

				// Process siblings
				tmp = iter;
				if (maptree_model.iter_next (ref iter)) {
					continue;
				}

				iter = tmp;

				// Process siblings of parent nodes we descended into
				while (!(exit = !maptree_model.iter_parent (out tmp, iter))) {
					iter = tmp;
					parent = parent.parent;

					tmp = iter;
					if (maptree_model.iter_next (ref iter)) {
						break;
					}
					iter = tmp;
				}
			}
		}

		writer.set_root (root);
		writer.generate ();
		writer.write (maps_path + "maptree.xml");
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
		try {
			parser.parse_file (map_filename);
			XmlNode map_node = parser.get_root ();

			var map = new Map ();
			map.load_data (map_node);
			this.maps.set (map_id, map);
			this.map_changes.set (map_id, new UndoManager.Stack (map));

			/* bind undo/redo changed signal handlers */
			this.map_changes.get (map_id).can_undo_changed.connect (this.update_undo_redo_buttons);
			this.map_changes.get (map_id).can_redo_changed.connect (this.update_undo_redo_buttons);
		}
		catch (Error e) {
			warning ("map %d could not be loaded: %s", map_id, e.message);
			/* TODO: show dialog? */
			return false;
		}

		return true;
	}

	/**
	 * Writes map data.
	 */
	public void save_map_data (int map_id) throws Error {
		// Map 0 (game_title) has nothing to save
		if (map_id == 0) {
			return;
		}

		XmlNode root;
		string map_file = this.base_path + "data/maps/map%d.xml".printf (map_id);
		var writer = new XmlWriter ();

		Map map = this.maps.get (map_id);
		map.save_data (out root);

		writer.set_root (root);
		writer.generate ();
		writer.write (map_file);

		// Clear map's undo history
		this.map_changes.set (map_id, new UndoManager.Stack (this.maps.get (map_id)));
		this.update_undo_redo_buttons ();
	}

	/**
	 * Writes all maps data.
	 */
	public void save_all_maps_data () {
		/*
		 * TODO: This is a thing we should think (and talk) about.
		 *
		 * A try/catch containing the foreach means that if a single map fails,
		 * the process stops and the remaining maps aren't saved.
		 *
		 * A try/catch containing the save_map_data () call implies that even if a
		 * single map fails, it will continue. For each map save fail there will be
		 * a dialog.
		 */
		try {
			foreach (int map_id in this.maps.get_keys ()) {
				this.save_map_data (map_id);
			}
		}
		catch (Error e) {
			// Show an error dialog
			var error_dialog = new Gtk.MessageDialog (
				this.main_window,
				Gtk.DialogFlags.MODAL|Gtk.DialogFlags.DESTROY_WITH_PARENT,
				Gtk.MessageType.ERROR, Gtk.ButtonsType.OK,
				e.message
			);
			error_dialog.run ();
			error_dialog.destroy ();
		}
	}

	/**
	 * Saves the current changes.
	 */
	public void save_changes () {
		try {
			// Write current map data
			this.save_map_data (this.current_map_id);

			// Build and updated maptree
			this.save_maptree_data ();
		}
		catch (Error e) {
			// Show an error dialog
			var error_dialog = new Gtk.MessageDialog (
				this.main_window,
				Gtk.DialogFlags.MODAL|Gtk.DialogFlags.DESTROY_WITH_PARENT,
				Gtk.MessageType.ERROR, Gtk.ButtonsType.OK,
				e.message
			);

			error_dialog.run ();
			error_dialog.destroy ();
		}
	}

	/**
	 * Opens the map specified by map_id.
	 */
	public void open_map (int map_id) {
		// If a map is already open, close it first
		if (this.current_map_id != 0) {
			this.close_map ();
		}

		// Don't try to open the map with id 0 (game_title)
		if (map_id == 0) {
			return;
		}
		
		// Get the map instance
		Map map = this.maps.get (map_id);

		// Load the tileset into the palette and the maprender
		var lower_layer_imageset = new RM2KChipsetLowerImageset (this.base_path + "graphics/tilesets/" + map.tileset);
		lower_layer_imageset.load_images ();
		var upper_layer_imageset = new RM2KChipsetUpperImageset (this.base_path + "graphics/tilesets/" + map.tileset);
		upper_layer_imageset.load_images ();

		// Get the palette ready
		var palette = this.main_window.drawingarea_palette;
		palette.lower_layer_imageset = lower_layer_imageset;
		palette.upper_layer_imageset = upper_layer_imageset;
		palette.load_tiles (this.main_window.get_current_layer ());
		palette.enable_draw ();

		if (this.main_window.get_current_layer () != LayerType.EVENT) {
			palette.enable_tile_selection ();
		}

		// Get the maprender ready
		var maprender = this.main_window.drawingarea_maprender;
		maprender.lower_layer_imageset = lower_layer_imageset;
		maprender.upper_layer_imageset = upper_layer_imageset;
		maprender.load_layer_schemes (map.lower_layer, map.upper_layer);
		maprender.set_current_layer (this.main_window.get_current_layer ());
		maprender.set_current_scale (this.main_window.get_current_scale ());
		maprender.set_current_drawing_tool (this.main_window.get_current_drawing_tool ());
		maprender.enable_draw ();

		if (this.main_window.get_current_layer () != LayerType.EVENT) {
			maprender.enable_tile_selection ();
		}

		// Update current_map id
		this.current_map_id = map_id;

		this.update_undo_redo_buttons ();
	}

	/**
	 * Closes current map.
	 */
	public void close_map () {
		// Clear the palette
		var palette = this.main_window.drawingarea_palette;
		palette.clear ();
		palette.disable_draw ();
		palette.disable_tile_selection ();

		// Clear the maprender
		var maprender = this.main_window.drawingarea_maprender;
		maprender.clear ();
		palette.disable_draw ();
		palette.disable_tile_selection ();

		this.current_map_id = 0;
	}

	/**
	 * FIXME
	 * This is a deprecated method that was being used for refreshing changes
	 * made to maps. Instead it should be replaced by a method that refreshes
	 * the map data, palette and/or maprender itself.
	 */
	public void reload_map () {
		int map_id = this.current_map_id;

		this.close_map ();
		this.open_map (map_id);
	}

	/**
	 * Returns the current map.
	 */
	public unowned Map get_map () {
		return this.maps.get (this.current_map_id);
	}

	/**
	 * Returns the changes done to the current map.
	 */
	public unowned UndoManager.Stack get_map_changes () {
		return this.map_changes.get (this.current_map_id);
	}

	/**
	 * Opens a dialog to create a new project and opens this project afterwards.
	 */
	public void create_project () {
		var dialog = new ProjectCreateDialog ();
		bool exit = false;

		while (!exit) {
			int result = dialog.run ();

			if (result == Gtk.ResponseType.OK) {
				try {
					/* Verify that project_path is a directory */
					var path = File.new_for_path (dialog.project_path);
					if (path.query_file_type (FileQueryInfoFlags.NONE) != FileType.DIRECTORY) {
						throw new FileError.NOTDIR ("Project path is not a directory!");
					}

					/* Verify that project_path is empty */
					var dir = Dir.open (dialog.project_path);
					if (dir.read_name () != null) {
						throw new FileError.FAILED ("Initial project directory is not empty!");
					}

					/* Create project description file */
					var unix_name = path.get_basename ();
					var rproject_path = path.get_child ("%s.rproject".printf (unix_name));
					var rproject_data = Resources.RPROJECT_DATA.printf(0, 0, 0);
					#if VALA_0_16
					rproject_path.replace_contents (rproject_data.data, null, false, FileCreateFlags.NONE, null, null);
					#else
					rproject_path.replace_contents (rproject_data, rproject_data.length, null, false, FileCreateFlags.NONE, null, null);
					#endif

					/* Create data/ */
					var data_path = path.get_child ("data");
					data_path.make_directory ();

					/* Create data/game.xml */
					var game_data = "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n<game>\n\t<title>%s</title>\n</game>".printf(dialog.project_name);
					var game_path = data_path.get_child ("game.xml");
					#if VALA_0_16
					game_path.replace_contents (game_data.data, null, false, FileCreateFlags.NONE, null, null);
					#else
					game_path.replace_contents (game_data, game_data.length, null, false, FileCreateFlags.NONE, null, null);
					#endif

					/* Load the new project */
					this.open_project (rproject_path.get_path ());

					/* Project created */
					exit = true;
				}
				catch (Error e) {
					/* Show Error Dialog */
					var edialog = new Gtk.MessageDialog (
						dialog,
						Gtk.DialogFlags.MODAL|Gtk.DialogFlags.DESTROY_WITH_PARENT,
						Gtk.MessageType.ERROR, Gtk.ButtonsType.OK,
						e.message
					);

					edialog.run ();
					edialog.destroy ();
				}
			}
			else {
				exit = true;
			}
		}

		dialog.destroy ();
	}

	/**
	 * Manages the reactions to the map selection.
	 */
	public void on_map_selected (int map_id) {
		// Don't react if the selected map is the current map
		if (map_id == this.current_map_id) {
			return;
		}

		this.open_map (map_id);
	}

	/**
	 * Manages the reactions to the map reordering.
	 */
	public void on_map_reordered(int map_id, Gtk.TreeRowReference map_new_reference) {
		// Insert (or update) the TreeRowReference for the corresponding map
		this.map_references.set (map_id, map_new_reference);
	}

	/**
	 * Manages the reactions to the map creation.
	 */
	public void on_map_new (int parent_map_id) {
		/* generate new map id */
		int new_map_id = 1;

		foreach (int key in maps.get_keys ()) {
			if (key >= new_map_id) {
				new_map_id = key + 1;
			}
		}

		/* create new map model */
		Map map = new Map ("Map%d".printf(new_map_id));

		var dialog = new MapPropertiesDialog (this, map);
		int result = dialog.run ();

		if (result == Gtk.ResponseType.OK) {
			/* load values from dialog */
			dialog.updateModel ();

			/* add map to list */
			this.maps.set (new_map_id, map);
			this.map_changes.set (new_map_id, new UndoManager.Stack (map));

			/* bind undo/redo changed signal handlers */
			this.map_changes.get (new_map_id).can_undo_changed.connect (this.update_undo_redo_buttons);
			this.map_changes.get (new_map_id).can_redo_changed.connect (this.update_undo_redo_buttons);

			/* get maptree model */
			var maptree_model = this.main_window.treeview_maptree.get_model () as MaptreeTreeStore;
			var map_icon = Resources.load_icon_as_pixbuf (Resources.ICON_MAP, 16);

			/* get correct position */
			Gtk.TreeIter iter;
			Gtk.TreeIter parent_iter;

			if (parent_map_id > 0) {
				maptree_model.get_iter (out parent_iter, this.map_references.get (parent_map_id).get_path ());
			}
			else {
				maptree_model.get_iter_first (out parent_iter);
			}

			/* append new map to parent */
			maptree_model.insert_before (out iter, parent_iter, null);

			/* set correct data */
			maptree_model.set_value (iter, 0, new_map_id);
			maptree_model.set_value (iter, 1, map_icon);
			maptree_model.set_value (iter, 2, map.name);

			/* save reference */
			var path = new Gtk.TreePath.from_string (maptree_model.get_string_from_iter (iter));
			var row_reference = new Gtk.TreeRowReference (maptree_model, path);
			this.map_references.set (new_map_id, row_reference);
		}

		dialog.destroy ();
	}

	/**
	 * Manages the reactions to the map properties.
	 */
	public void on_map_properties (int map_id) {
		Map map = this.maps.get (map_id);

		var dialog = new MapPropertiesDialog (this, map);
		int result = dialog.run ();

		if (result == Gtk.ResponseType.OK) {
			int width, height;

			/* get information about map size change */
			dialog.getSizeChange (out width, out height);

			/* update map model */
			dialog.updateModel ();

			/* update name in maptree */
			var maptree_model = this.main_window.treeview_maptree.get_model () as MaptreeTreeStore;
			Gtk.TreeIter iter;
			maptree_model.get_iter (out iter, this.map_references.get (map_id).get_path ());
			maptree_model.set_value (iter, 2, map.name);

			if (width != 0 || height != 0) {
				/* Reset UndoManager (TODO: make map size changes undoable) */
				this.map_changes.set (map_id, new UndoManager.Stack (map));
				this.update_undo_redo_buttons ();
			}

			/* reload map (size or tileset may have changed) */
			// FIXME: Re-render != open map again
			this.reload_map ();
		}

		dialog.destroy ();
	}

	/**
	 * Manages the reactions to the map deletion.
	 */
	public void on_map_delete (int map_id) {
		Map map = this.maps.get (map_id);

		var dialog = new Gtk.Dialog.with_buttons(
			"Delete Map?", this.main_window,
			Gtk.DialogFlags.MODAL | Gtk.DialogFlags.DESTROY_WITH_PARENT,
			Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL,
			Gtk.Stock.OK, Gtk.ResponseType.OK,
			null
		);

		var content_area = dialog.get_content_area () as Gtk.Box;
		content_area.pack_start (new Gtk.Label ("Map \"%s\" will be deleted. Proceed?".printf(map.name)), false);
		content_area.show_all ();

		int result = dialog.run ();
		if (result == Gtk.ResponseType.OK) {
			/* get maptree model and find correct entry */
			var maptree_model = this.main_window.treeview_maptree.get_model () as MaptreeTreeStore;

			Gtk.TreeIter iter;
			maptree_model.get_iter (out iter, this.map_references.get (map_id).get_path ());

			/* remove node including all children */
			foreach (int removed_map_id in maptree_model.remove_all (iter)) {
				this.map_references.remove (removed_map_id);
				this.maps.remove (removed_map_id);
				this.map_changes.remove (removed_map_id);
			}
		}

		dialog.destroy ();
	}

	/**
	 * Manages the reactions to the map shift.
	 */
	public void on_map_shift (int map_id) {
		var map = this.maps.get (map_id);
		var dialog = new MapShiftDialog ();

		int result = dialog.run ();
		if (result == Gtk.ResponseType.OK) {
			/* shift map */
			map.shift (dialog.dir, dialog.amount);

			/* Reset UndoManager (TODO: make map shift undoable) */
			this.map_changes.set (map_id, new UndoManager.Stack (map));
			this.update_undo_redo_buttons ();

			/* rerender map */
			// FIXME: Re-render != open map again
			this.reload_map ();
		}

		dialog.destroy ();
	}

	/**
	 * Manages the reactions to the undo button.
	 */
	public void on_undo () {
		var stack = this.get_map_changes () as UndoManager.Stack;

		if (stack != null) {
			stack.undo ();
			this.reload_map ();
		}
	}

	/**
	 * Manages the reactions to the redo button.
	 */
	public void on_redo () {
		var stack = this.get_map_changes () as UndoManager.Stack;

		if (stack != null) {
			stack.redo ();
			this.reload_map ();
		}
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
		about_dialog.set_transient_for (this.main_window);
		about_dialog.set_modal (true);
		about_dialog.set_version (Resources.APP_VERSION);
		about_dialog.set_license_type (Gtk.License.GPL_3_0);
		about_dialog.set_program_name (Resources.APP_NAME);
		about_dialog.set_comments ("A role playing game editor");
		about_dialog.set_website (Resources.APP_WEBSITE);
		about_dialog.set_copyright ("© EasyRPG Project 2011-2012");
		about_dialog.set_authors (Resources.APP_AUTHORS);
		about_dialog.set_artists (Resources.APP_ARTISTS);
		about_dialog.set_logo (Resources.load_icon_as_pixbuf ("easyrpg", 48));

		about_dialog.run ();
		about_dialog.destroy ();
	}

	private void update_undo_redo_buttons () {
		bool can_undo = false, can_redo = false;

		if (this.current_map_id != 0) {
			can_undo = this.map_changes.get (this.current_map_id).can_undo ();
			can_redo = this.map_changes.get (this.current_map_id).can_redo ();
		}

		this.main_window.set_undo_available (can_undo);
		this.main_window.set_redo_available (can_redo);
	}

	/**
	 * Print version information and exit
	 */
	static void show_version () {
		stdout.printf ("%s %s\n", Resources.APP_NAME, Resources.APP_VERSION);
	}

	/**
	 * The application entry point.
	 */
	static int main (string[] args) {
		Gtk.init (ref args);

		/* parse parameters from shell */
		var context = new OptionContext ("- EasyRPG Editor");
		context.set_help_enabled (true);
		context.add_main_entries (option_entries, "editor_vala");
		context.add_group (Gtk.get_option_group (true));

		try {
			context.parse (ref args);
		}
		catch (OptionError e) {
			stderr.puts (e.message + "\n");
			return 1;
		}

		if (opt_version) {
			show_version ();
			return 0;
		}

		var app = new Editor ();
		app.run ();

		Gtk.main ();

		return 0;
	}	
}

// Workaround
extern void gtk_file_filter_set_name (Gtk.FileFilter filter, string name);
