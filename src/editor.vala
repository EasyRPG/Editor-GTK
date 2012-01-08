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

const OptionEntry[] option_entries = {
	{ "", 0, 0, OptionArg.FILENAME_ARRAY, ref files, "input project file", "FILE" },
	{null}
};

static string[] files;

/**
 * Editor is the application class, the starting point for the app.
 */
public class Editor {
	private MainController main_controller;

	/**
	 * Instantiates the main controller.
	 */
	public Editor () {
		this.main_controller = new MainController (files != null ? files[0] : null);
	}

	/**
	 * Launches the main_controller's run method.
	 */
	public void run () {
		this.main_controller.run ();
	}

	/**
	 * The application entry point.
	 */
	static int main (string[] args) {
		Gtk.init (ref args);

		/* parse parameters from shell */
		var context = new OptionContext("- EasyRPG Editor");
		context.set_help_enabled(true);
		context.add_main_entries(option_entries, "editor_vala");
		context.add_group(Gtk.get_option_group(true));

		try {
			context.parse(ref args);
		} catch(OptionError e) {
			stderr.puts(e.message + "\n");
			return 1;
		}

		var app = new Editor ();
		app.run ();

		Gtk.main ();

		return 0;
	}
}
