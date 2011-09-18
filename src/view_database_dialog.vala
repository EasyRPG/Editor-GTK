/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * view_database_dialog.vala
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

public class DatabaseDialog : Gtk.Dialog {
	/*
	 * Properties
	 */
	private weak MainController controller;
	private ActorFrame actor_frame;
	private Gtk.Box actor_box;
	private Gtk.Box actor_list_box;
	private Gtk.Button button_set_max_actors;
	private Gtk.ListStore actor_list;
	private Gtk.Notebook notebook;
	private Gtk.TreeView actorlist_view;
	
	public DatabaseDialog (MainController controller) {
		/*
		 * Initialize properties
		 */
		this.controller = controller;
		this.set_title("Database");
		this.add_button (Gtk.Stock.OK, 0);
		this.add_button (Gtk.Stock.CANCEL, 1);
		this.add_button (Gtk.Stock.APPLY, 2);
		this.add_button (Gtk.Stock.HELP, 3);

		/*
		 * Initialize widgets
		 */
		this.actor_frame = new ActorFrame ();
		this.actor_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
		this.actor_list_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		this.button_set_max_actors = new Gtk.Button.with_label ("Max Number...");
		this.actor_list = new Gtk.ListStore (1, typeof (string));
		this.notebook = new Gtk.Notebook();
		this.actorlist_view = new Gtk.TreeView ();
		this.actorlist_view.set_model (actor_list);
		this.actorlist_view.set_size_request (200, -1);
		this.actorlist_view.insert_column_with_attributes (-1, "Characters", new Gtk.CellRendererText ());

		/*
		 * Dialog layout
		 */
		this.actor_list_box.pack_start (this.actorlist_view, true, true, 0);
		this.actor_list_box.pack_start (this.button_set_max_actors, false, true, 0);
		this.actor_box.pack_start (this.actor_list_box, false, true, 0);
		this.actor_box.pack_start (this.actor_frame, true, true, 0);

		Gtk.Box main_box = this.get_content_area () as Gtk.Box;		
		main_box.pack_start (this.notebook, true, true, 0);
		this.notebook.append_page (this.actor_box, new Gtk.Label ("Characters"));

		this.show_all ();

		/*
		 * Connect signals
		 */
		//this.response.connect(on_response);
		//this.close.connect (on_close);
	}

	/*
	 * On close
	 */
	[CCode (instance_pos = -1)]
	public void on_close (Gtk.Dialog dialog) {
		dialog.destroy ();
	}
}

public class ActorFrame : Gtk.Frame {
	/*
	 * Properties
	 */
	private Gtk.Button button_chose_chara;
	private Gtk.Button button_chose_face;
	private Gtk.Button button_edit_exp_curve;
	private Gtk.ComboBox combo_weapon;
	private Gtk.ComboBox combo_shield;
	private Gtk.ComboBox combo_armor;
	private Gtk.ComboBox combo_helmet;
	private Gtk.ComboBox combo_accesory;
	private Gtk.ComboBox no_weapon_animation;
	private Gtk.CheckButton check_has_critical;
	private Gtk.CheckButton check_dual_weapon;
	private Gtk.CheckButton check_fixed_equip;
	private Gtk.CheckButton check_use_ai;
	private Gtk.CheckButton check_strong_defense;
	private Gtk.CheckButton check_half_transparency;
	private Gtk.CheckButton use_custom_command;
	private Gtk.DrawingArea image_chara;
	private Gtk.DrawingArea image_face;
	private Gtk.DrawingArea image_hp_curve;
	private Gtk.DrawingArea image_mp_curve;
	private Gtk.DrawingArea image_atk_curve;
	private Gtk.DrawingArea image_def_curve;
	private Gtk.DrawingArea image_int_curve;
	private Gtk.DrawingArea image_dex_curve;
	private Gtk.Entry entry_name;
	private Gtk.Entry entry_title;
	private Gtk.Entry entry_exp_curve_details;
	private Gtk.Entry entry_custom_command_name;
	private Gtk.ListStore skill_list;
	private Gtk.ListStore state_suceptibility_list;
	private Gtk.ListStore atribute_efect_list;
	private Gtk.SpinButton entry_min_level;
	private Gtk.SpinButton entry_max_level;
	private Gtk.SpinButton entry_critical_rate;
	private Gtk.TreeView skill_display;
	private Gtk.TreeView state_display;
	private Gtk.TreeView atribute_display;

	public ActorFrame () {
		/*
		 * Initialize widgets
		 */
		this.button_chose_chara = new Gtk.Button.with_label ("Chose...");
		this.button_chose_face = new Gtk.Button.with_label ("Chose...");
		this.button_edit_exp_curve = new Gtk.Button.from_stock (Gtk.Stock.EDIT);
		this.combo_weapon = new Gtk.ComboBox ();
		this.combo_shield = new Gtk.ComboBox ();
		this.combo_armor = new Gtk.ComboBox ();
		this.combo_helmet = new Gtk.ComboBox ();
		this.combo_accesory = new Gtk.ComboBox ();
		this.no_weapon_animation = new Gtk.ComboBox ();
		this.check_has_critical = new Gtk.CheckButton ();
		this.check_dual_weapon = new Gtk.CheckButton.with_label ("Two Weapons");
		this.check_fixed_equip = new Gtk.CheckButton.with_label ("Lock Equipment");
		this.check_use_ai = new Gtk.CheckButton.with_label ("AI Control");
		this.check_strong_defense = new Gtk.CheckButton.with_label ("Strong Defense");
		this.check_half_transparency = new Gtk.CheckButton.with_label ("Transparent");
		this.use_custom_command = new Gtk.CheckButton.with_label ("Custom Skill Command");
		this.image_chara = new Gtk.DrawingArea();
		this.image_chara.set_size_request (48, 64);
		this.image_face = new Gtk.DrawingArea ();
		this.image_face.set_size_request (88, 88);
		this.image_hp_curve = new Gtk.DrawingArea ();
		this.image_hp_curve.set_size_request (96, 54);
		this.image_mp_curve = new Gtk.DrawingArea ();
		this.image_atk_curve = new Gtk.DrawingArea ();
		this.image_def_curve = new Gtk.DrawingArea ();
		this.image_int_curve = new Gtk.DrawingArea ();
		this.image_dex_curve = new Gtk.DrawingArea ();
		this.entry_name = new Gtk.Entry ();
		this.entry_title = new Gtk.Entry ();
		this.entry_exp_curve_details = new Gtk.Entry ();
		this.entry_exp_curve_details.set_can_focus (false);
		this.entry_custom_command_name = new Gtk.Entry ();
		this.skill_list = new Gtk.ListStore (2 , typeof (string), typeof (string));
		this.state_suceptibility_list = new Gtk.ListStore (2, typeof (Gtk.Image), typeof (string));
		this.atribute_efect_list = new Gtk.ListStore (2, typeof (Gtk.Image), typeof (string));
		this.entry_min_level = new Gtk.SpinButton (new Gtk.Adjustment (1, 1, 50, 1, 1, 1), 1, 2);
		this.entry_max_level = new Gtk.SpinButton (new Gtk.Adjustment (1, 1, 50, 1, 1, 1), 1, 2);
		this.entry_critical_rate = new Gtk.SpinButton (new Gtk.Adjustment (1, 1, 50, 1, 1, 1), 1, 2);
		this.skill_display = new Gtk.TreeView ();
		this.state_display = new Gtk.TreeView ();
		this.atribute_display = new Gtk.TreeView ();

		/*
		 * Initialize boxes
		 */
		var main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		var left_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var left_a_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0); /* for name, title, and chara */
		var name_title_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var chara_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		var chara_right_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var lvl_critic_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		var crit_rate_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		var face_chks_curve_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		var face_chks_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var face_button_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var chks_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var curve_column_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		var curve_a_row = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		curve_a_row.set_homogeneous (true);
		var curve_b_row = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		curve_b_row.set_homogeneous (true);
		var curve_exp_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		var right_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var equip_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		var equip_label_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var equip_combo_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var skills_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var skill_command_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		var stat_atribute_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		
		/*
		 * Initialize frames
		 */
		var name_frame = new Gtk.Frame ("Name");
		var title_frame = new Gtk.Frame ("Title");
		var chara_frame = new Gtk.Frame ("Chara Image");
		var min_lvl_frame = new Gtk.Frame ("Starting lvl");
		var max_lvl_frame = new Gtk.Frame ("Max. lvl");
		var crit_rate_frame = new Gtk.Frame ("Critical Rate");
		var face_frame = new Gtk.Frame ("Face Image");
		var curves_frame = new Gtk.Frame ("Parameters");
		var chks_frame = new Gtk.Frame ("Options");
		var curve_hp_frame = new Gtk.Frame ("Hit Points");
		var curve_mp_frame = new Gtk.Frame ("Magic Points");
		var curve_atk_frame = new Gtk.Frame ("Attack");
		var curve_def_frame = new Gtk.Frame ("Defense");
		var curve_int_frame = new Gtk.Frame ("Intelligence");
		var curve_dex_frame = new Gtk.Frame ("Agility");
		var curve_exp_frame = new Gtk.Frame ("Experience Curve");
		var equip_frame = new Gtk.Frame ("Starting Equipment");
		var battle_animation_frame = new Gtk.Frame ("Unarmed Battle Animation");
		var skills_frame = new Gtk.Frame ("Skills");
		var stat_frame = new Gtk.Frame ("Condition Resistance");
		var atrib_frame = new Gtk.Frame ("Attribute Resistance");
		
		/*
		 * Window layout
		 */
		// left_a_box
		name_frame.add (this.entry_name);
		title_frame.add (this.entry_title);
		name_title_box.pack_start (name_frame, false, true, 0);
		name_title_box.pack_start (title_frame, false, true, 0);

		chara_right_box.pack_start (this.check_half_transparency, false, true, 0);
		chara_right_box.pack_start (this.button_chose_chara, false, true, 0);
		chara_box.pack_start (this.image_chara, false, true, 0);
		chara_box.pack_start (chara_right_box, false, true, 0);
		chara_frame.add (chara_box);

		left_a_box.pack_start (name_title_box, false, true, 0);
		left_a_box.pack_start (chara_frame, false, true, 0);

		// lvl_critic_box
		min_lvl_frame.add (this.entry_min_level);
		max_lvl_frame.add (this.entry_max_level);

		crit_rate_box.pack_start (this.check_has_critical, false, true, 0);
		crit_rate_box.pack_start (this.entry_critical_rate, true, true, 0);
		crit_rate_frame.add(crit_rate_box);

		lvl_critic_box.pack_start (min_lvl_frame, true, true, 0);
		lvl_critic_box.pack_start (max_lvl_frame, true, true, 0);
		lvl_critic_box.pack_start (crit_rate_frame, true, true, 0);	

		// face_chks_curve_box
		curve_hp_frame.add (this.image_hp_curve);
		curve_atk_frame.add (this.image_atk_curve);
		curve_int_frame.add (this.image_int_curve);
		curve_a_row.pack_start(curve_hp_frame);
		curve_a_row.pack_start(curve_atk_frame);
		curve_a_row.pack_start(curve_int_frame);

		curve_mp_frame.add (this.image_mp_curve);
		curve_def_frame.add (this.image_def_curve);
		curve_dex_frame.add (this.image_dex_curve);
		curve_b_row.pack_start(curve_mp_frame);
		curve_b_row.pack_start(curve_def_frame);
		curve_b_row.pack_start(curve_dex_frame);

		curve_column_box.pack_start (curve_a_row, false, true, 0);
		curve_column_box.pack_start (curve_b_row, false, true, 0);
		curves_frame.add (curve_column_box);

		chks_box.pack_start (this.check_dual_weapon, false, true, 0);
		chks_box.pack_start (this.check_fixed_equip, false, true, 0);
		chks_box.pack_start (this.check_use_ai, false, true, 0);
		chks_box.pack_start (this.check_strong_defense, false, true, 0);
		chks_frame.add (chks_box);

		face_button_box.pack_start (this.image_face, false, true, 0);
		face_button_box.pack_start (this.button_chose_face, false, true, 0);
		face_frame.add (face_button_box);

		face_chks_box.pack_start (face_frame, false, true, 0);
		face_chks_box.pack_start (chks_frame, false, true, 0);	
		
		face_chks_curve_box.pack_start (curves_frame, false, true, 0);
		face_chks_curve_box.pack_start (face_chks_box, false, true, 0);

		// curve_exp_frame
		curve_exp_box.pack_start (this.entry_exp_curve_details, true, true, 0);
		curve_exp_box.pack_start (this.button_edit_exp_curve, false, false, 0);
		curve_exp_frame.add (curve_exp_box);

		// left_box
		left_box.pack_start (left_a_box, false, true, 0);
		left_box.pack_start (lvl_critic_box, false, true, 0);
		left_box.pack_start (face_chks_curve_box, false, false, 0);
		left_box.pack_start (curve_exp_frame, true, true, 0);				

		// equip_frame
		equip_label_box.pack_start (new Gtk.Label ("Weapon:"), true, true, 10);
		equip_label_box.pack_start (new Gtk.Label ("Shield:"), true, true, 10);
		equip_label_box.pack_start (new Gtk.Label ("Armor:"), true, true, 10);
		equip_label_box.pack_start (new Gtk.Label ("Helmet:"), true, true, 10);
		equip_label_box.pack_start (new Gtk.Label ("Accesory:"), true, true, 10);

		equip_combo_box.pack_start (this.combo_weapon, true, true, 10);
		equip_combo_box.pack_start (this.combo_shield, true, true, 10);
		equip_combo_box.pack_start (this.combo_armor, true, true, 10);
		equip_combo_box.pack_start (this.combo_helmet, true, true, 10);
		equip_combo_box.pack_start (this.combo_accesory, true, true, 10);

		equip_box.pack_start (equip_label_box, false, true, 0);
		equip_box.pack_start (equip_combo_box, true, true, 0);
		equip_frame.add (equip_box);

		// battle_animation_frame
		battle_animation_frame.add (this.no_weapon_animation);

		// skills_frame
		skill_command_box.pack_start (this.use_custom_command, false, true, 0);
		skill_command_box.pack_start (this.entry_custom_command_name, true, true, 0);

		skills_box.pack_start (this.skill_display, true, true, 0);
		skills_box.pack_start (skill_command_box, false, true, 0);
		skills_frame.add (skills_box);

		// stat_atribute_box
		stat_frame.add (this.state_display);
		atrib_frame.add (this.atribute_display);
		stat_atribute_box.pack_start (stat_frame, true, true, 0);
		stat_atribute_box.pack_start (atrib_frame, true, true, 0);

		// right_box
		right_box.pack_start (equip_frame, false, true, 0);
		right_box.pack_start (battle_animation_frame,false, true, 0);
		right_box.pack_start (skills_frame, false, true, 0);
		right_box.pack_start (stat_atribute_box, false, true, 0);

		// main_box
		main_box.pack_start (left_box, true, true, 0);
		main_box.pack_start (right_box, false, true, 0);
				
		this.add (main_box);
	}
}