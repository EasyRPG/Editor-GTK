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

public class ActorFrame : IndexSelector {
	/*
	 * Properties
	 */
	private Gtk.Notebook notebook;
	private ActorGeneralSettings view_general_settings;
	private ActorGraphics view_graphic_settings;
	private ActorCurve view_curve_settings;
	/*
	 * Constructor
	 */
	public ActorFrame () {
		base("Characters");
		/*
		 * Initialize widgets
		 */
		this.notebook = new Gtk.Notebook();
		this.view_general_settings = new ActorGeneralSettings();
		this.view_graphic_settings = new ActorGraphics();
		this.view_curve_settings = new ActorCurve();

		//Do layout
		this.notebook.append_page(view_general_settings, new Gtk.Label("General"));
		this.notebook.append_page(view_graphic_settings, new Gtk.Label("Graphics"));
		this.notebook.append_page(view_curve_settings, new Gtk.Label("Curves"));
		this.set_child(notebook);
	}
}

public class ActorGeneralSettings : Gtk.Frame {
	/*
	 * Properties
	 */
	private GroupFrame frame_identify;
	private GroupFrame frame_leveling;
	private GroupFrame frame_miscellaneous;
	private GroupFrame frame_profession;
	private Gtk.Entry entry_name;
	private Gtk.Entry entry_title;
	private Gtk.SpinButton spin_initial_lvl;
	private Gtk.SpinButton spin_final_lvl;
	private Gtk.SpinButton spin_critical_rate;
	private Gtk.Adjustment adjustment_final_level;
	private Gtk.CheckButton check_dual_weapon;
	private Gtk.CheckButton check_fixed_equipment;
	private Gtk.CheckButton check_ai_control;
	private Gtk.CheckButton check_strong_deffense;
	private Gtk.CheckButton check_critical_chance;
	private Gtk.ComboBox combo_profession;
	private Gtk.Button button_apply_profession;

	/*
	 * Constructor
	 */
	public ActorGeneralSettings (){
		//Initialize widgets
		this.frame_identify = new GroupFrame ("Identification");
		this.frame_leveling = new GroupFrame ("Levelling");
		this.frame_miscellaneous = new GroupFrame("Miscellaneous");
		this.frame_profession = new GroupFrame("Profession");
		this.entry_name = new Gtk.Entry();
		this.entry_title = new Gtk.Entry();
		this.adjustment_final_level = new Gtk.Adjustment(0,1,100,1,1,1);
		this.spin_initial_lvl = new Gtk.SpinButton(new Gtk.Adjustment(0, 1, 100, 1, 1, 1), 1, 0);
		this.spin_final_lvl = new Gtk.SpinButton(adjustment_final_level, 1, 0);
		this.spin_critical_rate = new Gtk.SpinButton(new Gtk.Adjustment(0, 1, 101, 1, 1, 1), 1, 0);
		this.check_dual_weapon = new Gtk.CheckButton();
		this.check_fixed_equipment = new Gtk.CheckButton();
		this.check_ai_control = new Gtk.CheckButton();
		this.check_strong_deffense = new Gtk.CheckButton();
		this.check_critical_chance = new Gtk.CheckButton();
		this.combo_profession = new Gtk.ComboBox();
		this.button_apply_profession = new Gtk.Button.from_stock(Gtk.Stock.APPLY);

		/*
		 * Set properties
		 */
		this.check_dual_weapon.set_label("Dual weapon mode");
		this.check_fixed_equipment.set_label("Use fixed equipment");
		this.check_ai_control.set_label("AI - Control");
		this.check_strong_deffense.set_label("Strong defense");
		this.check_critical_chance.set_label("Critical chance:");
		this.check_critical_chance.set_size_request(80, -1);
		this.spin_critical_rate.set_size_request(50, -1);
		this.button_apply_profession.set_size_request(100, -1);
		this.combo_profession.set_size_request(300, -1);

		//Layout frame_identify
		string[] labels = {};
		labels += "Name:";
		labels += "Title:";
		Gtk.Entry[] entries = {};
		entries += this.entry_name;
		entries += this.entry_title;
		this.frame_identify.add_entries (labels, entries);

		//Layout frame_leveling
		labels = {};
		labels += "Initial:";
		labels += "Maximum:";
		Gtk.SpinButton[] spin_buttons = {};
		spin_buttons += this.spin_initial_lvl;
		spin_buttons += this.spin_final_lvl;
		this.frame_leveling.add_spin_buttons (labels, spin_buttons);
		
		//Layout frame_miscellaneous
		Gtk.CheckButton[] check_buttons = {};
		check_buttons += this.check_dual_weapon;
		check_buttons += this.check_fixed_equipment;
		check_buttons += this.check_ai_control;
		check_buttons += this.check_strong_deffense;
		var box_critical = new Gtk.HBox (false, 0);
		box_critical.pack_start(this.check_critical_chance, false, true, 0);
		box_critical.pack_start(this.spin_critical_rate, false, true, 13);
		this.frame_miscellaneous.add_check_buttons(check_buttons);
		this.frame_miscellaneous.add_widget(box_critical, false, true, 2);

		//Layout frame_profession
		var box_profession = new Gtk.VBox (false, 10);
		box_profession.pack_start(this.combo_profession, true, true, 0);
		box_profession.pack_start(this.button_apply_profession, false, true, 0);
		this.frame_profession.add_widget(box_profession, true, false, 0);

		//Do main layout
		var box_main = new Gtk.VBox (false, 3);
		box_main.pack_start(this.frame_identify, false, true, 0);
		box_main.pack_start(this.frame_leveling, false, true, 0);
		box_main.pack_start(this.frame_miscellaneous, false, true, 0);
		//FIXME: should remove profession feature?
		//box_main.pack_start(this.frame_profession, false, true, 0);
		this.add(box_main);
	}
}

	public class ActorGraphics : Gtk.Frame {
		/*
		 * Properties
		 */
		private GroupFrame frame_face;
		private GroupFrame frame_chara;
		private GroupFrame frame_animation;
		private ImageFrame view_face;
		private AnimatedFrame view_chara;
		private AnimatedFrame view_battler;
		private AnimatedFrame view_weaponless_animation;
		//FIXME: not actually Animated_Frame, but a class to render battle animations
		private Gtk.Button button_chose_face;
		private Gtk.Button button_chose_chara;
		private Gtk.CheckButton check_use_transparency;
		private Gtk.ComboBox combo_battler;
		private Gtk.ComboBox combo_weaponless_animation;
		

		/*
		 * Constructor
		 */
		public ActorGraphics(){
			//Initialize widgets
			this.frame_face = new GroupFrame ("Face");
			this.frame_chara = new GroupFrame ("Map Graphic");
			this.frame_animation = new GroupFrame ("Battle Animations", Gtk.Orientation.HORIZONTAL);
			this.view_face = new ImageFrame (48, 48);
			this.view_chara = new AnimatedFrame (48, 48);
			this.view_battler = new AnimatedFrame (48, 48);
			this.view_weaponless_animation = new AnimatedFrame (48, 48);
			this.button_chose_face = new Gtk.Button.with_label("Chose ...");
			this.button_chose_chara = new Gtk.Button.with_label("Chose ...");
			this.combo_battler = new Gtk.ComboBox();
			this.combo_weaponless_animation = new Gtk.ComboBox();
			var box_main = new Gtk.VBox (false, 2);
			var box_battler = new Gtk.VBox (false, 0);
			var box_weaponless_animation = new Gtk.VBox (false, 0);

			//Layout frame_face
			this.frame_face.add_widget (view_face, true, true, 0);
			this.frame_face.add_widget (button_chose_face, true, true, 0);

			//Layout frame_chara
			this.frame_chara.add_widget (view_chara, true, true, 0);
			this.frame_chara.add_widget (button_chose_chara, true, true, 0);

			//Layout frame_animation
			box_battler.pack_start (view_battler, false, true, 0);
			box_battler.pack_start (combo_battler,false, true, 0);
			box_weaponless_animation.pack_start (view_weaponless_animation, false, true, 0);
			box_weaponless_animation.pack_start (combo_weaponless_animation, false, true, 0);
			frame_animation.add_widget(box_battler, true, true, 0);
			frame_animation.add_widget(box_weaponless_animation, true, true, 0);
			
			//Do main layout
			box_main.pack_start(frame_face, false, false, 0);
			box_main.pack_start(frame_chara, false, false, 0);
			box_main.pack_start(frame_animation, false, false, 0);
			
			this.add(box_main);
		}
}

public class ActorCurve : Gtk.Frame{
	/*
	 * Properties
	 */
	private Gtk.Notebook notebook;
	private CurveFrame view_hp;
	private CurveFrame view_mp;
	private CurveFrame view_att;
	private CurveFrame view_def;
	private CurveFrame view_int;
	private CurveFrame view_dex;

	/*
	 * Constructor
	 */
	public ActorCurve (){
		//Initialize widgets
		this.notebook = new Gtk.Notebook();
		this.view_hp = new CurveFrame(Gdk.Color());
		this.view_mp = new CurveFrame(Gdk.Color());
		this.view_att = new CurveFrame(Gdk.Color());
		this.view_def = new CurveFrame(Gdk.Color());
		this.view_int = new CurveFrame(Gdk.Color());
		this.view_dex = new CurveFrame(Gdk.Color());

		//Set properties
		this.notebook.set_tab_pos(Gtk.PositionType.BOTTOM);

		//Do Layout
		this.notebook.append_page(this.view_hp, new Gtk.Label ("Max Hp"));
		this.notebook.append_page(this.view_mp, new Gtk.Label ("Max Mp"));
		this.notebook.append_page(this.view_att, new Gtk.Label ("Max Attack"));
		this.notebook.append_page(this.view_def, new Gtk.Label ("Max Defense"));
		this.notebook.append_page(this.view_int, new Gtk.Label ("Max Spirit"));
		this.notebook.append_page(this.view_dex, new Gtk.Label ("Max Speed"));
		this.add(notebook);
	}
}

/**
 * This class has the apearence of every curve tab.
 */
public class CurveFrame : Gtk.Frame{
	/*
	 * Properties
	 */
	private Gdk.Color color;
	private GroupFrame frame_curve;
	private GroupFrame frame_level;
	private GroupFrame frame_value;
	private GroupFrame frame_easy_choice;
	private Gtk.SpinButton spin_lvl;
	private Gtk.SpinButton spin_value;
	private Gtk.Button button_create;
	private Gtk.Button button_great;
	private Gtk.Button button_good;
	private Gtk.Button button_normal;
	private Gtk.Button button_low;
	private Gtk.DrawingArea view_curve;

	/*
	 * Constructor
	 * 
	 * @param color a Gdk.color indicating what color should the curve be drawn.
	 */
	public CurveFrame (Gdk.Color color) {
		this.color = color;
		this.frame_curve = new GroupFrame ("Curve");
		this.frame_level = new GroupFrame ("Level");
		this.frame_value = new GroupFrame ("Value");
		this.frame_easy_choice = new GroupFrame ("Easy choice");
		this.spin_lvl = new Gtk.SpinButton (new Gtk.Adjustment(1, 1, 100, 1, 1, 1), 1, 0);
		this.spin_value = new Gtk.SpinButton (new Gtk.Adjustment(1, 1, 1000, 1, 1, 1), 1, 0);
		this.button_create = new Gtk.Button.with_label("Create ...");
		this.button_great = new Gtk.Button.with_label("Great");
		this.button_good = new Gtk.Button.with_label("Good");
		this.button_normal = new Gtk.Button.with_label("Normal");
		this.button_low = new Gtk.Button.with_label("Low");
		this.view_curve = new Gtk.DrawingArea();

		//Layout frame_level
		this.frame_level.add_widget(this.spin_lvl, false, true, 0);

		//Layout frame_value
		this.frame_value.add_widget(this.spin_value, false, true, 0);

		

		//Layout frame_curve
		
		
		
	}
}
