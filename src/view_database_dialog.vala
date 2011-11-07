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

/**
 * The database window view.
 */
public class DatabaseDialog : Gtk.Dialog {
	/*
	 * Properties
	 */
	private weak MainController controller;
	private ActorFrame actor_frame;
	private Gtk.Notebook notebook;

	/**
	 * Builds the database interface.
	 * 
	 * @param controller A reference to the controller that launched this view.
	 */
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
		this.notebook = new Gtk.Notebook();
		/*
		 * Dialog layout
		 */
		
		Gtk.Box main_box = this.get_content_area () as Gtk.Box;		
		main_box.pack_start (this.notebook, true, true, 0);
		this.notebook.append_page (this.actor_frame, new Gtk.Label ("Actors"));

		this.show_all ();

		/*
		 * Connect signals
		 */
		//this.response.connect(on_response);
		//this.close.connect (on_close);
	}

	/**
	 * Closes this view.
	 */
	public void on_close (Gtk.Dialog dialog) {
		dialog.destroy ();
	}
}
