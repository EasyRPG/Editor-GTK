/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * editor.vala
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

public class DataBaseDialog : Gtk.Dialog
{
	private Gtk.Notebook notebook;
	private Gtk.ListStore actor_list;
	private Gtk.TreeView actorlist_view;
	private ActorFrame actor_frame;
	private Gtk.Button button_set_max_actors;
	
	public DataBaseDialog()
	{
		this.set_title("Data Base");
		this.add_button (Gtk.Stock.OK, 0);
		this.add_button (Gtk.Stock.CANCEL, 1);
		this.add_button (Gtk.Stock.APPLY, 2);
		this.add_button (Gtk.Stock.HELP, 3);
		
		/* Create Widgets */
		notebook = new Gtk.Notebook();


		/******************
		 *	 Page Actors  *
		 ******************/
		actor_list = new Gtk.ListStore (1, typeof (string));
		actorlist_view = new Gtk.TreeView ();
		actorlist_view.set_model (actor_list);
		actorlist_view.set_size_request (200, -1);
		actorlist_view.insert_column_with_attributes (-1, "Characters", new Gtk.CellRendererText ());
		actor_frame = new ActorFrame ();
		button_set_max_actors = new Gtk.Button ();
		button_set_max_actors.set_label ("Max Number...");
		/* Create Containers */
		var actor_list_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var actor_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
		/* Layaut Actor tab */
		actor_list_box.pack_start (actorlist_view, true, true, 0);
		actor_list_box.pack_start (button_set_max_actors, false, true, 0);
		actor_box.pack_start (actor_list_box, false, true, 0);
		actor_box.pack_start (actor_frame, true, true, 0);

		Gtk.Box main_box = this.get_content_area () as Gtk.Box;		
		main_box.pack_start (notebook, true, true, 0);
		notebook.append_page (actor_box, new Gtk.Label ("Actors"));
		
		/* Connect actions and widgets */
		this.response.connect(on_response);

		this.show_all ();
	}
	private void on_response()
	{
		/* TODO: manage response */
	}
}

public class ActorFrame : Gtk.Frame
{
	private Gtk.Entry entry_name;
	private Gtk.Entry entry_title;
	private Gtk.DrawingArea image_chara;
	private Gtk.CheckButton check_half_transparency;
	private Gtk.Button button_chose_chara;
	private Gtk.SpinButton entry_min_level;
	private Gtk.SpinButton entry_max_level;
	private Gtk.CheckButton check_has_critical;
	private Gtk.SpinButton entry_critical_rate;
	private Gtk.DrawingArea image_face;
	private Gtk.Button button_chose_face;
	private Gtk.CheckButton check_dual_weapon;
	private Gtk.CheckButton check_fixed_equip;
	private Gtk.CheckButton check_use_ai;
	private Gtk.CheckButton check_strong_defense;
	private Gtk.DrawingArea image_hp_curve;
	private Gtk.DrawingArea image_mp_curve;
	private Gtk.DrawingArea image_atk_curve;
	private Gtk.DrawingArea image_def_curve;
	private Gtk.DrawingArea image_int_curve;
	private Gtk.DrawingArea image_dex_curve;
	private Gtk.Entry entry_exp_curve_details;
	private Gtk.Button button_edit_exp_curve;
	private Gtk.ComboBox combo_weapon;
	private Gtk.ComboBox combo_shield;
	private Gtk.ComboBox combo_armor;
	private Gtk.ComboBox combo_helmet;
	private Gtk.ComboBox combo_accesory;
	private Gtk.ComboBox no_weapon_animation;
	private Gtk.TreeView skill_display;
	private Gtk.ListStore skill_list;
	private Gtk.CheckButton use_custom_command;
	private Gtk.Entry entry_custom_command_name;
	private Gtk.TreeView state_display;
	private Gtk.ListStore state_suceptibility_list;
	private Gtk.TreeView atribute_display;
	private Gtk.ListStore atribute_efect_list;

	public ActorFrame ()
	{
		/* Create widgets */
		entry_name = new Gtk.Entry ();
		entry_title = new Gtk.Entry ();
		image_chara = new Gtk.DrawingArea();
		image_chara.set_size_request (48, 64);
		check_half_transparency = new Gtk.CheckButton ();
		check_half_transparency.set_label ("Use transparency");
		button_chose_chara = new Gtk.Button ();
		button_chose_chara.set_label ("Chose...");
		entry_min_level = new Gtk.SpinButton (new Gtk.Adjustment (1, 1, 50, 1, 1, 1), 1, 2);
		entry_max_level = new Gtk.SpinButton (new Gtk.Adjustment (1, 1, 50, 1, 1, 1), 1, 2);
		check_has_critical = new Gtk.CheckButton ();
		entry_critical_rate = new Gtk.SpinButton (new Gtk.Adjustment (1, 1, 50, 1, 1, 1), 1, 2);
		image_face = new Gtk.DrawingArea ();
		image_face.set_size_request (88, 88);
		button_chose_face = new Gtk.Button ();
		button_chose_face.set_label ("Chose...");
		check_dual_weapon = new Gtk.CheckButton ();
		check_dual_weapon.set_label ("Dual weapon mode");
		check_fixed_equip = new Gtk.CheckButton ();
		check_fixed_equip.set_label ("Fixed Equipment");
		check_use_ai = new Gtk.CheckButton ();
		check_use_ai.set_label ("AI Control");
		check_strong_defense = new Gtk.CheckButton ();
		check_strong_defense.set_label ("String defense");
		image_hp_curve = new Gtk.DrawingArea ();
		image_hp_curve.set_size_request (96, 54);
		image_mp_curve = new Gtk.DrawingArea ();
		image_atk_curve = new Gtk.DrawingArea ();
		image_def_curve = new Gtk.DrawingArea ();
		image_int_curve = new Gtk.DrawingArea ();
		image_dex_curve = new Gtk.DrawingArea ();
		entry_exp_curve_details = new Gtk.Entry ();
		entry_exp_curve_details.set_can_focus (false);
		button_edit_exp_curve = new Gtk.Button.from_stock (Gtk.Stock.EDIT);
		combo_weapon = new Gtk.ComboBox ();
		combo_shield = new Gtk.ComboBox ();
		combo_armor = new Gtk.ComboBox ();
		combo_helmet = new Gtk.ComboBox ();
		combo_accesory = new Gtk.ComboBox ();
		no_weapon_animation = new Gtk.ComboBox ();
		skill_display = new Gtk.TreeView ();
		skill_list = new Gtk.ListStore (2 , typeof (string), typeof (string));
		use_custom_command = new Gtk.CheckButton ();
		use_custom_command.set_label ("Custom battle command");
		entry_custom_command_name = new Gtk.Entry ();
		state_display = new Gtk.TreeView ();
		state_suceptibility_list = new Gtk.ListStore (2, typeof (Gtk.Image), typeof (string));
		atribute_display = new Gtk.TreeView ();
		atribute_efect_list = new Gtk.ListStore (2, typeof (Gtk.Image), typeof (string));

		/* Create Containers */
		var main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		var left_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var left_a_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0); /* for name, title, and chara */
		var name_title_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var name_frame = new Gtk.Frame ("Name");
		var title_frame = new Gtk.Frame ("Title");
		var chara_frame = new Gtk.Frame ("Walking Graphic");
		var chara_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		var chara_right_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var lvl_critic_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		var min_lvl_frame = new Gtk.Frame ("Initial lvl");
		var max_lvl_frame = new Gtk.Frame ("Maximum lvl");
		var crit_rate_frame = new Gtk.Frame ("Critical Rate");
		var crit_rate_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		var face_chks_curve_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		var face_chks_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var face_frame = new Gtk.Frame ("Face Graphic");
		var face_button_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var chks_frame = new Gtk.Frame ("Options");
		var chks_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var curves_frame = new Gtk.Frame ("Evolution Curves");
		var curve_column_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		var curve_a_row = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		curve_a_row.set_homogeneous (true);
		var curve_b_row = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		curve_b_row.set_homogeneous (true);
		var curve_hp_frame = new Gtk.Frame ("MAX Hit Poits");
		var curve_mp_frame = new Gtk.Frame ("MAX Magic Poits");
		var curve_atk_frame = new Gtk.Frame ("Attack");
		var curve_def_frame = new Gtk.Frame ("Defense");
		var curve_int_frame = new Gtk.Frame ("Intelligence");
		var curve_dex_frame = new Gtk.Frame ("Speed");
		var curve_exp_frame = new Gtk.Frame ("Experience Curve");
		var curve_exp_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		var right_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var equip_frame = new Gtk.Frame ("Initial Equipment");
		var equip_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		var equip_label_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var equip_combo_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var battle_animation_frame = new Gtk.Frame ("Non weapon battle animation");
		var skills_frame = new Gtk.Frame ("Skills");
		var skills_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var skill_command_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		var stat_atribute_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		var stat_frame = new Gtk.Frame ("Status efectiveness");
		var atrib_frame = new Gtk.Frame ("Atribute efectiveness");
		
		/* Do Layaut */
		main_box.pack_start (left_box, true, true, 0);
			left_box.pack_start (left_a_box, false, true, 0);
				left_a_box.pack_start (name_title_box, false, true, 0);
					name_title_box.pack_start (name_frame, false, true, 0);
						name_frame.add (entry_name);
					name_title_box.pack_start (title_frame, false, true, 0);
						title_frame.add (entry_title);
				left_a_box.pack_start (chara_frame, false, true, 0);
					chara_frame.add (chara_box);
						chara_box.pack_start (image_chara, false, true, 0);
						chara_box.pack_start (chara_right_box, false, true, 0);
							chara_right_box.pack_start (check_half_transparency, false, true, 0);
							chara_right_box.pack_start (button_chose_chara, false, true, 0);
			left_box.pack_start (lvl_critic_box, false, true, 0);
				lvl_critic_box.pack_start (min_lvl_frame, true, true, 0);
					min_lvl_frame.add (entry_min_level);
				lvl_critic_box.pack_start (max_lvl_frame, true, true, 0);
					max_lvl_frame.add (entry_max_level);
				lvl_critic_box.pack_start (crit_rate_frame, true, true, 0);
					crit_rate_frame.add(crit_rate_box);
						crit_rate_box.pack_start (check_has_critical, false, true, 0);
						crit_rate_box.pack_start (entry_critical_rate, true, true, 0);
			left_box.pack_start (face_chks_curve_box, false, false, 0);
				face_chks_curve_box.pack_start (face_chks_box, false, true, 0);
					face_chks_box.pack_start (face_frame, false, true, 0);
						face_frame.add (face_button_box);
							face_button_box.pack_start (image_face, false, true, 0);
							face_button_box.pack_start (button_chose_face, false, true, 0);
					face_chks_box.pack_start (chks_frame, false, true, 0);
						chks_frame.add (chks_box);
							chks_box.pack_start (check_dual_weapon, false, true, 0);
							chks_box.pack_start (check_fixed_equip, false, true, 0);
							chks_box.pack_start (check_use_ai, false, true, 0);
							chks_box.pack_start (check_strong_defense, false, true, 0);
				face_chks_curve_box.pack_start (curves_frame, false, true, 0);
					curves_frame.add (curve_column_box);
						curve_column_box.pack_start (curve_a_row, false, true, 0);
							curve_a_row.pack_start(curve_hp_frame);
								curve_hp_frame.add (image_hp_curve);
							curve_a_row.pack_start(curve_atk_frame);
								curve_hp_frame.add (image_atk_curve);
							curve_a_row.pack_start(curve_int_frame);
								curve_hp_frame.add (image_int_curve);
						curve_column_box.pack_start (curve_b_row, false, true, 0);
							curve_b_row.pack_start(curve_mp_frame);
								curve_hp_frame.add (image_mp_curve);
							curve_b_row.pack_start(curve_def_frame);
								curve_hp_frame.add (image_def_curve);
							curve_b_row.pack_start(curve_dex_frame);
								curve_hp_frame.add (image_dex_curve);
			left_box.pack_start (curve_exp_frame, true, true, 0);
				curve_exp_frame.add (curve_exp_box);
					curve_exp_box.pack_start (entry_exp_curve_details, true, true, 0);
					curve_exp_box.pack_start (button_edit_exp_curve, false, false, 0);
		main_box.pack_start (right_box, false, true, 0);
			right_box.pack_start (equip_frame, false, true, 0);
				equip_frame.add (equip_box);
					equip_box.pack_start (equip_label_box, false, true, 0);
						equip_label_box.pack_start (new Gtk.Label ("Weapon:"), true, true, 10);
						equip_label_box.pack_start (new Gtk.Label ("Shield:"), true, true, 10);
						equip_label_box.pack_start (new Gtk.Label ("Armor:"), true, true, 10);
						equip_label_box.pack_start (new Gtk.Label ("Helmet:"), true, true, 10);
						equip_label_box.pack_start (new Gtk.Label ("Accesory:"), true, true, 10);
					equip_box.pack_start (equip_combo_box, true, true, 0);
						equip_combo_box.pack_start (combo_weapon, true, true, 10);
						equip_combo_box.pack_start (combo_shield, true, true, 10);
						equip_combo_box.pack_start (combo_armor, true, true, 10);
						equip_combo_box.pack_start (combo_helmet, true, true, 10);
						equip_combo_box.pack_start (combo_accesory, true, true, 10);
			right_box.pack_start (battle_animation_frame,false, true, 0);
				battle_animation_frame.add (no_weapon_animation);
			right_box.pack_start (skills_frame, false, true, 0);
				skills_frame.add (skills_box);
					skills_box.pack_start (skill_display, true, true, 0);
					skills_box.pack_start (skill_command_box, false, true, 0);
						skill_command_box.pack_start (use_custom_command, false, true, 0);
						skill_command_box.pack_start (entry_custom_command_name, true, true, 0);
			right_box.pack_start (stat_atribute_box, false, true, 0);
				stat_atribute_box.pack_start (stat_frame, true, true, 0);
					stat_frame.add (state_display);
				stat_atribute_box.pack_start (atrib_frame, true, true, 0);
					atrib_frame.add (atribute_display);
				
		this.add (main_box);
	}
}