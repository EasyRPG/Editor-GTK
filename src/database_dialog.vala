/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * Copyright (C) 2011 EasyRPG Project
 *
 * License: https://github.com/EasyRPG/Editor/blob/master/COPYING GPL
 *
 * Authors:
 * - Aitor García (Falc) <aitor.falc@gmail.com>
 * - Mariano Suligoy (MarianoGNU) <marianognu.easyrpg@gmail.com>
 */

/**
 * The database window view.
 */
public class DatabaseDialog : Gtk.Dialog {
	/*
	 * Properties
	 */
	private weak Editor editor;
	private ActorFrame actor_frame;
	private Gtk.Notebook notebook;

	/**
	 * Builds the database interface.
	 * 
	 * @param editor A reference to the Editor class.
	 */
	public DatabaseDialog (Editor editor) {
		/*
		 * Initialize properties
		 */
		this.editor = editor;
		this.set_title("Database");
		this.add_button (Resources.STOCK_LABEL_OK, 0);
		this.add_button (Resources.STOCK_LABEL_CANCEL, 1);
		this.add_button (Resources.STOCK_LABEL_APPLY, 2);
		this.add_button (Resources.STOCK_LABEL_HELP, 3);

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
