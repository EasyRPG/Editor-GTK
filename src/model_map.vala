/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * model_map.vala
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
 * Represents a map object in the editor. 
 */
public class Map : Model {
	/**
	 * Map name. Not unique.
	 */
	public string name {get; set; default = "";}

	/**
	 * Parent map id.
	 * 
	 * Id 0 means no parent map.
	 */
	public int parent_id {get; set; default = 0;}

	/**
	 * Map order regarding to the parent.
	 * 
	 * Default is 0.
	 * 0 means first map.
	 * 
	 * When two or more maps have the same order number, the id is mandatory and
	 * the map with the lowest id goes first. Then the order should be updated.
	 */
	public int order {get; set; default = 0;}

	/**
	 * Map width in tiles.
	 * 
	 * Default is 20.
	 */
	public int width {get; set; default = 20;}

	/**
	 * Map height in tiles.
	 * 
	 * Default is 15.
	 */
	public int height {get; set; default = 15;}

	/**
	 * Scroll type of the map.
	 * 
	 * 0: No scroll. (Default)
	 * 1: Vertical loop only.
	 * 2: Horizontal loop only.
	 * 3: Both vertical and horizontal.
	 */
	public int scroll_type {get; set; default = 0;}

	/**
	 * Defines whether the map uses a panorama.
	 * 
	 * Default is false.
	 */
	public bool panorama_use {get; set; default = false;}

	/**
	 * Panorama filename.
	 * 
	 * This property is ignored if panorama_use is false.
	 */
	public string panorama_filename {get; set; default = "";}

	/**
	 * Defines whether the panorama loops horizontally.
	 * 
	 * Default is false.
	 */
	public bool panorama_horizontal_loop {get; set; default = false;}

	/**
	 * Defines whether the panorama loops vertically.
	 * 
	 * Default is false.
	 */
	public bool panorama_vertical_loop {get; set; default = false;}

	/**
	 * Defines whether the panorama autoscrolls horizontally.
	 * 
	 * Default is false.
	 * 
	 * This property is ignored if panorama_horizontal_loop is false.
	 */
	public bool panorama_horizontal_autoscroll {get; set; default = false;}

	/**
	 * Horizontal autoscroll speed.
	 * 
	 * Default is 0. It must be a number between -8 and 8.
	 * 
	 * This property is ignored if panorama_horizontal_loop is false or
	 * panorama_horizontal_autoscroll is true.
	 */
	public int panorama_horizontal_autoscroll_speed {get; set; default = 0;}

	/**
	 * Defines whether the panorama autoscrolls vertically.
	 * 
	 * Default is false.
	 * 
	 * This property is ignored if panorama_vertical_loop is false.
	 */
	public bool panorama_vertical_autoscroll {get; set; default = false;}

	/**
	 * Vertical autoscroll speed.
	 * 
	 * Default is 0. It must be a number between -8 and 8.
	 * 
	 * This property is ignored if panorama_vertical_loop is false or
	 * panorama_vertical_autoscroll is true.
	 */
	public int panorama_vertical_autoscroll_speed {get; set; default = 0;}

	/**
	 * BGM type.
	 * 
	 * 0: Same as parent map. (Default)
	 * 1: Entrust to event.
	 * 2: Specify.
	 */
	public int bgm_type {get; set; default = 0;}

	/**
	 * BGM filename.
	 * 
	 * This property is ignored if bgm_type != 2.
	 */
	public string bgm_filename {get; set; default = "";}

	/**
	 * Backdrop type.
	 * 
	 * 0: Same as parent map. (Default)
	 * 1: Entrust to event.
	 * 2: Specify.
	 */
	public int backdrop_type {get; set; default = 0;}

	/**
	 * Backdrop filename.
	 * 
	 * This property is ignored if backdrop_type != 2.
	 */
	public string backdrop_filename {get; set; default = "";}

	/**
	 * Teleport type.
	 * 
	 * 0: Same as parent map. Unavailable if there is no parent map.
	 * 1: Entrust to event.
	 * 2: Specify.
	 */
	public int teleport_type {get; set;}

	/**
	 * Defines whether teleport is allowed.
	 * 
	 * Default is true.
	 * 
	 * This property is ignored if teleport_type != 2.
	 */
	public bool teleport_allow {get; set; default = true;}

	/**
	 * Escape type.
	 * 
	 * 0: Same as parent map. Unavailable if there is no parent map.
	 * 1: Entrust to event.
	 * 2: Specify.
	 */
	public int escape_type {get; set;}

	/**
	 * Defines whether escape from battle is allowed.
	 * 
	 * Default is true.
	 * 
	 * This property is ignored if escape_type != 2.
	 */
	public bool escape_allow {get; set; default = true;}

	/**
	 * Save type.
	 * 
	 * 0: Same as parent map. Unavailable if there is no parent map.
	 * 1: Entrust to event.
	 * 2: Specify.
	 */
	public int save_type {get; set;}

	/**
	 * Defines whether save is allowed.
	 * 
	 * Default is true.
	 * 
	 * This property is ignored if save_type != 2.
	 */
	public bool save_allow {get; set; default = true;}

	/**
	 * Model containing layer data.
	 */
	public Layer[] layers {get; set;}

	/**
	 * Determines how often a battle will happen.
	 * 
	 * Default is 25.
	 */
	public int enemy_encounter_steps {get; set; default = 25;}

	/**
	 * While loading save data, if this element is modified, the event execution
	 * state will be reloaded.
	 */
	public int save_time {get; set;}

	/**
	 * Loads the map data from an XmlNode object.
	 * 
	 * @param data An XmlNode that contains the map data.
	 */
	public override void load_data (XmlNode data) {
		string name = "";
		int parent_id = 0;
		int order = 0;
		int width = 0;
		int height = 0;
		int scroll_type = 0;
		string panorama_filename = "";
		bool panorama_horizontal_loop = false;
		bool panorama_horizontal_autoscroll = false;
		int panorama_horizontal_autoscroll_speed = 0;
		bool panorama_vertical_loop = false;
		bool panorama_vertical_autoscroll = false;
		int panorama_vertical_autoscroll_speed = 0;
		int bgm_type = 0;
		string bgm_filename = "";
		int backdrop_type = 0;
		string backdrop_filename = "";
		int teleport_type = 0;
		bool teleport_allow = false;
		int escape_type = 0;
		bool escape_allow = false;
		int save_type = 0;
		bool save_allow = false;
		Layer[] layers = {};
		int enemy_encounter_steps = 0;
		int save_time = 0;

		int i = 0;
		while(i < data.get_children_num ()) {
			switch (data.get_child(i).name) {
				case "name":
					name = data.get_child(i).content;
					break;
				case "parent_id":
					parent_id = int.parse (data.get_child(i).content);
					break;
				case "order":
					order = int.parse (data.get_child(i).content);
					break;
				case "width":
					width = int.parse (data.get_child(i).content);
					break;
				case "height":
					height = int.parse (data.get_child(i).content);
					break;
				case "scroll_type":
					scroll_type = int.parse (data.get_child(i).content);
					break;
				case "panorama":
					XmlNode panorama = data.get_child(i);
					
					int j = 0;
					while(j < panorama.get_children_num ()) {
						switch (panorama.get_child(j).name) {
							case "filename":
								panorama_filename = panorama.get_child(j).content;
								break;
							case "horizontal_loop":
								panorama_horizontal_loop = bool.parse (panorama.get_child(j).content);
								break;
							case "horizontal_autoscroll":
								panorama_horizontal_autoscroll = bool.parse (panorama.get_child(j).content);
								break;
							case "horizontal_autoscroll_speed":
								panorama_horizontal_autoscroll_speed = int.parse (panorama.get_child(j).content);
								break;
							case "vertical_loop":
								panorama_vertical_loop = bool.parse (panorama.get_child(j).content);
								break;
							case "vertical_autoscroll":
								panorama_vertical_autoscroll = bool.parse (panorama.get_child(j).content);
								break;
							case "vertical_autoscroll_speed":
								panorama_vertical_autoscroll_speed = int.parse (panorama.get_child(j).content);
								break;
							default:
								break;
						}
						j++;
					}
					break;
				case "bgm":
					XmlNode bgm = data.get_child(i);
					
					int j = 0;
					while(j < bgm.get_children_num ()) {
						switch (bgm.get_child(j).name) {
							case "type":
								bgm_type = int.parse (bgm.get_child(j).content);
								break;
							case "filename":
								bgm_filename = bgm.get_child(j).content;
								break;
							default:
								break;
						}
						j++;
					}
					break;
				case "backdrop":
					XmlNode backdrop = data.get_child(i);
					
					int j = 0;
					while(j < backdrop.get_children_num ()) {
						switch (backdrop.get_child(j).name) {
							case "type":
								backdrop_type = int.parse (backdrop.get_child(j).content);
								break;
							case "filename":
								backdrop_filename = backdrop.get_child(j).content;
								break;
							default:
								break;
						}
						j++;
					}
					break;
				case "teleport":
					XmlNode teleport = data.get_child(i);
					
					int j = 0;
					while(j < teleport.get_children_num ()) {
						switch (teleport.get_child(j).name) {
							case "type":
								teleport_type = int.parse (teleport.get_child(j).content);
								break;
							case "allow":
								teleport_allow = bool.parse (teleport.get_child(j).content);
								break;
							default:
								break;
						}
						j++;
					}
					break;
				case "escape":
					XmlNode escape = data.get_child(i);
					
					int j = 0;
					while(j < escape.get_children_num ()) {
						switch (escape.get_child(j).name) {
							case "type":
								escape_type = int.parse (escape.get_child(j).content);
								break;
							case "allow":
								escape_allow = bool.parse (escape.get_child(j).content);
								break;
							default:
								break;
						}
						j++;
					}
					break;
				case "save":
					XmlNode save = data.get_child(i);
					
					int j = 0;
					while(j < save.get_children_num ()) {
						switch (save.get_child(j).name) {
							case "type":
								save_type = int.parse (save.get_child(j).content);
								break;
							case "allow":
								save_allow = bool.parse (save.get_child(j).content);
								break;
							default:
								break;
						}
						j++;
					}
					break;
				case "layers":
					XmlNode layers_data = data.get_child(i);
					
					int j = 0;
					while(j < layers_data.get_children_num ()) {
						switch (layers_data.get_child(j).name) {
							case "layer":
								Layer layer = new Layer();
								layer.load_data (layers_data.get_child(j));
								layers += layer;
								break;
							default:
								break;
						}
						j++;
					}
					break;
				case "enemy_encounter_steps":
					enemy_encounter_steps = int.parse (data.get_child(i).content);
					break;
				case "save_time":
					save_time = int.parse (data.get_child(i).content);
					break;
				default:
					break;
			}
			i++;
		}

		/*
		 * Check the parsed values to make sure they are valid.
		 * 
		 * It is not neccessary to modify a property if the parsed value match
		 * the default one or is not valid. Also, some dependent properties
		 * can be ignored if they are not going to be used.
		 */
		this.name = (name == "") ? "Untitled" : name;

		// FIXME: check if the parent map xml file exists 
		if (parent_id < 0) {
			parent_id = 0;
		}
		else {
			// Check parent
		}

		this.order = (order < 0) ? 0 : order;

		// Set a non-default width only when the parsed value is valid
		if (width > 20) {
			this.width = width;
		}

		// Set a non-default height only when the parsed value is valid
		if (height > 15) {
			this.height = height;
		}

		this.scroll_type = (scroll_type < 0) ? 0 : order;

		// If the map does not use a panorama ignore its related values
		if (panorama_filename != "") {
			this.panorama_use = true;
			this.panorama_filename = panorama_filename;

			this.panorama_horizontal_loop = panorama_horizontal_loop;
			this.panorama_vertical_loop = panorama_vertical_loop;

			// The autoscroll configuration is only needed for panoramas with loop
			if (panorama_horizontal_loop == true) {
				this.panorama_horizontal_autoscroll = panorama_horizontal_autoscroll;

				// The autoscroll speed is only needed for non-autoscroll panoramas
				if (panorama_horizontal_autoscroll == false) {
					this.panorama_horizontal_autoscroll_speed = panorama_horizontal_autoscroll_speed;
				}
			}

			// The autoscroll configuration is only needed for panoramas with loop
			if (panorama_vertical_loop == true) {
				this.panorama_vertical_autoscroll = panorama_vertical_autoscroll;

				// The autoscroll speed is only needed for non-autoscroll panoramas
				if (panorama_vertical_autoscroll == false) {
					this.panorama_vertical_autoscroll_speed = panorama_vertical_autoscroll_speed;
				}
			}
		}

		this.bgm_type = (bgm_type < 0) ? 0 : bgm_type;
		if (bgm_type == 2) {
			// FIXME: check if file exists
			this.bgm_filename = bgm_filename;
		}

		this.backdrop_type = (backdrop_type < 0 ) ? 0 : backdrop_type;
		if (backdrop_type == 2) {
			// FIXME: check if file exists
			this.backdrop_filename = backdrop_filename;
		}

		this.teleport_type = (teleport_type < 0) ? 0 : teleport_type;
		if (teleport_type == 2) {
			this.teleport_allow = teleport_allow;
		}

		this.escape_type = (escape_type < 0) ? 0 : escape_type;
		if (escape_type == 2) {
			this.escape_allow = escape_allow;
		}

		this.save_type = (save_type < 0) ? 0 : save_type;
		if (save_type == 2) {
			this.save_allow = save_allow;
		}

		/*
		 * This is the place where the layer tile_id checks should be made, but
		 * it could be interesting to make them at map rendering time.
		 */
		this.layers = layers;

		this.enemy_encounter_steps = (enemy_encounter_steps < 0) ? 0 : enemy_encounter_steps;

		this.save_time = (save_time < 0) ? 0 : save_time;
	}

	/**
	 * Prints the map data.
	 */
	public void print_data () {
		print ("********************************\n");
		print ("MAP DATA\n");
		print ("********************************\n");
		print ("Name: %s\n", this.name);
		print ("Parent id: %i\n", this.parent_id);
		print ("Order: %i\n", this.order);
		print ("Width: %i\n", this.width);
		print ("Height: %i\n", this.height);
		print ("Scroll type: %i\n", this.scroll_type);
		print ("Panorama:\n");
		print ("  Filename: %s\n", this.panorama_filename);
		print ("  Horz loop: %s\n", (this.panorama_horizontal_loop == true) ? "TRUE" : "FALSE");
		print ("  Horz autoscroll: %s\n", (this.panorama_horizontal_autoscroll == true) ? "TRUE" : "FALSE");
		print ("  Horz autoscroll speed: %i\n", this.panorama_horizontal_autoscroll_speed);
		print ("  Vert loop: %s\n", (this.panorama_vertical_loop == true) ? "TRUE" : "FALSE");
		print ("  Vert autoscroll: %s\n", (this.panorama_vertical_autoscroll == true) ? "TRUE" : "FALSE");
		print ("  Vert autoscroll speed: %i\n", this.panorama_vertical_autoscroll_speed);
		print ("BGM type: %i\n", this.bgm_type);
		print ("BGM filename: %s\n", this.bgm_filename);
		print ("Backdrop type: %i\n", this.backdrop_type);
		print ("Backdrop filename: %s\n", this.backdrop_filename);
		print ("Teleport type: %i\n", this.teleport_type);
		print ("Teleport allowed: %s\n", (this.teleport_allow == true) ? "TRUE" : "FALSE");
		print ("Escape type: %i\n", this.escape_type);
		print ("Escape allowed: %s\n", (this.escape_allow == true) ? "TRUE" : "FALSE");
		print ("Save type: %i\n", this.save_type);
		print ("Save allowed: %s\n", (this.save_allow == true) ? "TRUE" : "FALSE");
		foreach (Layer layer in this.layers) {
			layer.print_data ();
		}
		print ("Enemy encounter steps: %i\n", this.enemy_encounter_steps);
		print ("Save time: %i\n\n", this.save_time);
	}
}