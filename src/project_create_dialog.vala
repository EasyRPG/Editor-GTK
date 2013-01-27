/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * Copyright (C) 2012 EasyRPG Project
 *
 * License: https://github.com/EasyRPG/Editor/blob/master/COPYING GPL
 *
 * Authors:
 * - Sebastian Reichel (sre) <sre@ring0.de>
 * - Aitor García (Falc) <aitor.falc@gmail.com>
 */

/**
 * The create project window view.
 */
public class ProjectCreateDialog : Gtk.Dialog {
	public bool project_compability {get; private set; default = false;}
	public string project_name {get; private set; default = "EasyRPG Game";}
	public string project_path  {get; private set;}

	/**
	 * Builds the map shift window.
	 */
	public ProjectCreateDialog  (string? name=null, bool compability=false, string? path=null) {
		Gtk.Box content = this.get_content_area () as Gtk.Box;

		/* Init dialog */
		this.set_title("New Project");
		this.add_button (Gtk.Stock.CANCEL, Gtk.ResponseType.CANCEL);
		this.add_button (Gtk.Stock.OK, Gtk.ResponseType.OK);

		/* Layout */
		var input_name        = new Gtk.Entry ();
		var frame_name        = new Gtk.Frame ("Game Name");
		var input_path        = new Gtk.FileChooserWidget (Gtk.FileChooserAction.SELECT_FOLDER);
		var frame_path        = new Gtk.Frame ("Project Path");
		var input_compability = new Gtk.CheckButton.with_label ("only allow RPG Maker compatible features");

		frame_name.add (input_name);
		frame_path.add (input_path);

		content.pack_start (frame_name, false, false, 5);
		content.pack_start (frame_path, true, true, 5);
		content.pack_start (input_compability, false, false, 5);

		/* increase default size of the selection widget */
		int width_minimal, width_natural, height_minimal, height_natural;
		input_path.get_preferred_width (out width_minimal, out width_natural);
		input_path.get_preferred_height (out height_minimal, out height_natural);
		input_path.set_size_request (width_natural+300, height_natural+150);

		/* Initial values */
		input_name.text = (name == null) ? this.project_name : name;
		input_compability.set_active (compability);
		if(path != null)
			input_path.select_filename (path);

		input_compability.toggled.connect (() => {
			this.project_compability = input_compability.get_active ();
		});

		input_name.changed.connect (() => {
			this.project_name = input_name.get_text ();
		});

		input_path.selection_changed.connect (() => {
			this.project_path = input_path.get_filename ();
		});

		/* not yet supported */
		input_compability.set_active (true);
		input_compability.set_sensitive (false);

		this.show_all ();
	}
}
