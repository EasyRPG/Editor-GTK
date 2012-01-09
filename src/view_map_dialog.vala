/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * view_database_dialog.vala
 * Copyright (C) EasyRPG Project 2012
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
 * TODO:
 *  - FileChooserButton should probably show only Project Ressources
 *  - FileChooserButton result is currently neither loaded nor saved
 */

/**
 * The map properties window view.
 */
public class MapPropertiesDialog : Gtk.Dialog {
	private Gtk.Notebook notebook;
	private BasicPage page1;
	private Map model;

	private class BasicPage : Gtk.Box {
		private Gtk.Entry input_name;
		private Gtk.ComboBoxText input_tileset;
		private Gtk.SpinButton input_width;
		private Gtk.SpinButton input_height;
		private OptionTable options;
		private PanoramaTable panorama;

		public BasicPage (MainController controller, Map map) {
			Object(orientation: Gtk.Orientation.HORIZONTAL, spacing:5, halign:Gtk.Align.START, valign:Gtk.Align.START);

			var left_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 5);

			var frame_name = new Gtk.Frame ("Name");
			input_name = new Gtk.Entry ();
			input_name.set_text (map.name);
			frame_name.add (input_name);
			left_box.pack_start (frame_name, true, false);

			var frame_tileset = new Gtk.Frame ("Tileset");
			input_tileset = new Gtk.ComboBoxText ();
			foreach (var tileset in controller.getTilesets ())
				input_tileset.append (tileset, tileset);
			input_tileset.set_active_id (map.tileset);
			frame_tileset.add (input_tileset);
			left_box.pack_start (frame_tileset, true, false);

			var frame_dimensions = new Gtk.Frame ("Dimensions");
			var table_dimensions = new Gtk.Table (2, 2, false);
			input_width = new Gtk.SpinButton (new Gtk.Adjustment ((double) map.width, 1.0, 500.0, 1.0, 5.0, 0.0), 1.0, 0);
			input_height = new Gtk.SpinButton (new Gtk.Adjustment ((double) map.height, 1.0, 500.0, 1.0, 5.0, 0.0), 1.0, 0);
			table_dimensions.attach_defaults (new Gtk.Label ("Width:"), 0, 1, 0, 1);
			table_dimensions.attach_defaults (input_width, 1, 2, 0, 1);
			table_dimensions.attach_defaults (new Gtk.Label ("Height:"), 0, 1, 1, 2);
			table_dimensions.attach_defaults (input_height, 1, 2, 1, 2);
			frame_dimensions.add (table_dimensions);
			left_box.pack_start (frame_dimensions, true, false);

			var frame_options = new Gtk.Frame ("Options");
			options = new OptionTable (map);
			frame_options.add (options);
			left_box.pack_start (frame_options, true, false);

			this.pack_start (left_box, true, false);

			var frame_panorama = new Gtk.Frame ("Background");
			panorama = new PanoramaTable (map);
			frame_panorama.add (panorama);
			this.pack_start (frame_panorama, true, false);
		}

		public void updateModel (Map map) {
			map.name = input_name.get_text ().dup ();
			map.tileset = input_tileset.get_active_id ();
			map.width = input_width.get_value_as_int ();
			map.height = input_height.get_value_as_int ();

			options.updateModel (map);
			panorama.updateModel (map);
		}
	}

	private class PanoramaTable : Gtk.Table {
		private Gtk.CheckButton        input_enabled;
		private Gtk.CheckButton        input_h_scroll;
		private Gtk.CheckButton        input_h_auto;
		private Gtk.SpinButton         input_h_speed;
		private Gtk.CheckButton        input_v_scroll;
		private Gtk.CheckButton        input_v_auto;
		private Gtk.SpinButton         input_v_speed;
		private Gtk.Image              output_image;
		private Gtk.FileChooserButton  input_image;

		public PanoramaTable (Map map) {
			Object(n_rows: 2, n_columns:2, homogeneous:false);

			input_enabled = new Gtk.CheckButton.with_label ("Use Panorama Background");
			input_enabled.set_active (map.panorama_use);
			this.attach_defaults (input_enabled, 0, 2, 0, 1);

			var frame_image = new Gtk.Frame ("Image");
			var box_image = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

			output_image = new Gtk.Image.from_file (map.panorama_filename);
			output_image.set_size_request (320, 240);
			box_image.pack_start (output_image, true, false);

			input_image = new Gtk.FileChooserButton ("Choose Image", Gtk.FileChooserAction.OPEN);
			box_image.pack_start (input_image, true, false);

			frame_image.add (box_image); 
			this.attach_defaults (frame_image, 0, 1, 1, 2);

			var box_scrolling = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

			var frame_h_scrolling = new Gtk.Frame ("Horizontal Scrolling");
			var box_h_scrolling = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
			input_h_scroll = new Gtk.CheckButton.with_label ("Use Horizontal Scroll");
			input_h_scroll.set_active (map.panorama_horizontal_loop);
			box_h_scrolling.pack_start (input_h_scroll, true, false);
			input_h_auto = new Gtk.CheckButton.with_label ("Autoscroll");
			input_h_auto.set_active (map.panorama_horizontal_autoscroll);
			box_h_scrolling.pack_start (input_h_auto, true, false);
			input_h_speed = new Gtk.SpinButton (new Gtk.Adjustment (map.panorama_horizontal_autoscroll_speed, -8.0, 8.0, 1.0, 1.0, 0.0), 1.0, 0);
			box_h_scrolling.pack_start (input_h_speed, true, false);
			frame_h_scrolling.add (box_h_scrolling);

			var frame_v_scrolling = new Gtk.Frame ("Vertical Scrolling");
			var box_v_scrolling = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
			input_v_scroll = new Gtk.CheckButton.with_label ("Use Vertical Scroll");
			input_v_scroll.set_active (map.panorama_vertical_loop);
			box_v_scrolling.pack_start (input_v_scroll, true, false);
			input_v_auto = new Gtk.CheckButton.with_label ("Autoscroll");
			input_v_auto.set_active (map.panorama_vertical_autoscroll);
			box_v_scrolling.pack_start (input_v_auto, true, false);
			input_v_speed = new Gtk.SpinButton (new Gtk.Adjustment (map.panorama_vertical_autoscroll_speed, -8.0, 8.0, 1.0, 1.0, 0.0), 1.0, 0);
			box_v_scrolling.pack_start (input_v_speed, true, false);
			frame_v_scrolling.add (box_v_scrolling);

			box_scrolling.pack_start (frame_h_scrolling, true, false);
			box_scrolling.pack_start (frame_v_scrolling, true, false);
			this.attach_defaults (box_scrolling, 1, 2, 1, 2);

			input_enabled.toggled.connect (update_sensitivity);
			input_h_scroll.toggled.connect (update_sensitivity);
			input_v_scroll.toggled.connect (update_sensitivity);
			input_h_auto.toggled.connect (update_sensitivity);
			input_v_auto.toggled.connect (update_sensitivity);

			update_sensitivity ();
		}

		private void update_sensitivity () {
			bool bg_enabled = input_enabled.get_active ();
			bool h_scroll   = input_h_scroll.get_active ();
			bool v_scroll   = input_v_scroll.get_active ();
			bool h_auto     = input_h_auto.get_active ();
			bool v_auto     = input_v_auto.get_active ();

			input_image.set_sensitive (bg_enabled);
			output_image.set_sensitive (bg_enabled);
			input_h_scroll.set_sensitive (bg_enabled);
			input_v_scroll.set_sensitive (bg_enabled);
			input_h_auto.set_sensitive (bg_enabled && h_scroll);
			input_v_auto.set_sensitive (bg_enabled && v_scroll);
			input_h_speed.set_sensitive (bg_enabled && h_scroll && h_auto);
			input_v_speed.set_sensitive (bg_enabled && v_scroll && v_auto);
		}

		public void updateModel (Map map) {
			map.panorama_use = input_enabled.get_active ();
			//map.panorama_filename = input_image.get_file ().get_path ();
			map.panorama_horizontal_loop = input_h_scroll.get_active ();
			map.panorama_vertical_loop = input_v_scroll.get_active ();
			map.panorama_horizontal_autoscroll = input_h_auto.get_active ();
			map.panorama_vertical_autoscroll = input_v_auto.get_active ();
			map.panorama_horizontal_autoscroll_speed = input_h_speed.get_value_as_int ();
			map.panorama_vertical_autoscroll_speed = input_v_speed.get_value_as_int ();
		}
	}

	private class OptionTable : Gtk.Table {
		private Gtk.ComboBoxText      input_teleport;
		private Gtk.ComboBoxText      input_escape;
		private Gtk.ComboBoxText      input_save;
		private Gtk.ComboBoxText      input_wrapping;
		private Gtk.ComboBoxText      input_music;
		private Gtk.FileChooserButton input_music_file;
		private Gtk.ComboBoxText      input_bbg;
		private Gtk.FileChooserButton input_bbg_file;

		public OptionTable (Map map) {
			Object(n_rows: 6, n_columns:3, homogeneous:false);

			var str_teleport = new Gtk.Label ("Teleport:");
			str_teleport.set_halign (Gtk.Align.START);
			str_teleport.set_tooltip_markup ("allow or forbid the ability to teleport out of the map");
			attach_defaults (str_teleport, 0, 1, 0, 1);

			var str_escape = new Gtk.Label ("Escape:");
			str_escape.set_halign (Gtk.Align.START);
			str_escape.set_tooltip_markup ("allow or forbid the ability to escape out of fights");
			attach_defaults (str_escape, 0, 1, 1, 2);

			var str_save = new Gtk.Label ("Save:");
			str_save.set_halign (Gtk.Align.START);
			str_save.set_tooltip_markup ("allow or forbid saving in the map");
			attach_defaults (str_save, 0, 1, 2, 3);

			var str_wrapping = new Gtk.Label ("Wrapping:");
			str_wrapping.set_halign (Gtk.Align.START);
			str_wrapping.set_tooltip_markup ("appear on the other side of the map, when walking across the map borders");
			attach_defaults (str_wrapping, 0, 1, 3, 4);

			var str_music = new Gtk.Label ("Background Music:");
			str_music.set_halign (Gtk.Align.START);
			attach_defaults (str_music, 0, 1, 4, 5);

			var str_bbg = new Gtk.Label ("Battle Background:");
			str_bbg.set_halign (Gtk.Align.START);
			attach_defaults (str_bbg, 0, 1, 5, 6);

			input_teleport = new Gtk.ComboBoxText ();
			input_teleport.append ("parent", "same as parent map");
			input_teleport.append ("event", "entrust to event");
			input_teleport.append ("allow", "allow");
			input_teleport.append ("forbid", "forbid");
			input_teleport.set_active (model_to_combobox (map.teleport_type, map.teleport_allow));
			attach_defaults (input_teleport, 1, 3, 0, 1);

			input_escape = new Gtk.ComboBoxText ();
			input_escape.append ("parent", "same as parent map");
			input_escape.append ("event", "entrust to event");
			input_escape.append ("allow", "allow");
			input_escape.append ("forbid", "forbid");
			input_escape.set_active (model_to_combobox (map.escape_type, map.escape_allow));
			attach_defaults (input_escape, 1, 3, 1, 2);

			input_save = new Gtk.ComboBoxText ();
			input_save.append ("parent", "same as parent map");
			input_save.append ("event", "entrust to event");
			input_save.append ("allow", "allow");
			input_save.append ("forbid", "forbid");
			input_save.set_active (model_to_combobox (map.save_type, map.save_allow));
			attach_defaults (input_save, 1, 3, 2, 3);

			input_wrapping = new Gtk.ComboBoxText ();
			input_wrapping.append ("none", "None");
			input_wrapping.append ("vertical", "Vertical");
			input_wrapping.append ("horizontal", "Horizontal");
			input_wrapping.append ("both", "Both");
			input_wrapping.set_active (map.scroll_type);
			attach_defaults (input_wrapping, 1, 3, 3, 4);

			input_music = new Gtk.ComboBoxText ();
			input_music.append ("parent", "same as parent map");
			input_music.append ("event", "entrust to event");
			input_music.append ("specify", "specify");
			input_music.set_active (map.bgm_type);
			attach_defaults (input_music, 1, 2, 4, 5);

			input_music_file = new Gtk.FileChooserButton ("Choose Soundtrack", Gtk.FileChooserAction.OPEN);
			attach_defaults (input_music_file, 2, 3, 4, 5);

			input_bbg = new Gtk.ComboBoxText ();
			input_bbg.append ("parent", "same as parent map");
			input_bbg.append ("terrain", "use terrain settings");
			input_bbg.append ("specify", "specify");
			input_bbg.set_active (map.backdrop_type);
			attach_defaults (input_bbg, 1, 2, 5, 6);

			input_bbg_file = new Gtk.FileChooserButton ("Choose Image", Gtk.FileChooserAction.OPEN);
			attach_defaults (input_bbg_file, 2, 3, 5, 6);

			input_music.changed.connect (update_sensitivity);
			input_bbg.changed.connect (update_sensitivity);

			update_sensitivity ();
		}

		private int model_to_combobox (int type, bool allow) {
			if (type == 2)
				return allow ? 2 : 3;
			else
				return type;
		}

		private void combobox_to_model (int value, out int type, out bool allow) {
			if (value == 2 || value == 3) {
				type = 2;
				allow = value == 2;
			} else {
				type = value;
				allow = true;
			}
		}

		private void update_sensitivity () {
			bool music = input_music.get_active_id () == "specify";
			bool bbg   = input_bbg.get_active_id () == "specify";

			input_music_file.set_sensitive (music);
			input_bbg_file.set_sensitive (bbg);
		}

		public void updateModel (Map map) {
			int type;
			bool allow;

			map.scroll_type = input_wrapping.get_active ();

			map.bgm_type = input_music.get_active ();
			//map.bgm_filename = input_music_file.get_file ().get_path ();

			map.backdrop_type = input_bbg.get_active ();
			//map.backdrop_file = input_bbg_file.get_file ().get_path ();

			combobox_to_model (input_teleport.get_active (), out type, out allow);
			map.teleport_type = type;
			map.teleport_allow = allow;

			combobox_to_model (input_escape.get_active (), out type, out allow);
			map.escape_type = type;
			map.escape_allow = allow;

			combobox_to_model (input_save.get_active (), out type, out allow);
			map.save_type = type;
			map.save_allow = allow;
		}
	}

	/**
	 * Builds the map properties window.
	 */
	public MapPropertiesDialog (MainController controller, Map map) {
		this.model = map;

		/* Initialize Dialog */
		this.set_title ("Map Properties");
		this.add_button (Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL);
		this.add_button (Gtk.Stock.OK, Gtk.ResponseType.OK);

		/* Initialize Widgets */
		this.notebook = new Gtk.Notebook ();
		this.notebook.set_scrollable (true);
		this.page1 = new BasicPage (controller, map);

		/* Dialog Layout */
		Gtk.Box main_box = this.get_content_area () as Gtk.Box;		
		main_box.pack_start (this.notebook, true, true, 0);

		this.notebook.append_page (this.page1, new Gtk.Label ("Basic Settings"));
		this.notebook.append_page (new Gtk.Label ("This feature is not yet supported by the Editor."), new Gtk.Label ("Enemy Settings"));
		this.notebook.append_page (new Gtk.Label ("This feature is not yet supported by the Editor."), new Gtk.Label ("Dungeon Generator"));

		this.show_all ();
	}

	public void updateModel () {
		page1.updateModel (model);
	}
}
