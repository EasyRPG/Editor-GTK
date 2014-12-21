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
 * The module list window view.
 */
public class ModuleListDialog : Gtk.Dialog {
	/*
	 * Properties
	 */
	private weak Editor editor;
	private Gtk.ScrolledWindow scrolled;
	private Gtk.TextView view;
	/**
	 * Builds the module list  interface.
	 * 
	 * @param editor A reference to the Editor class.
	 */
	public ModuleListDialog (Editor editor) {
		/*
		 * Initialize properties
		 */
		this.editor = editor;
		this.set_title("Modules");
		this.add_button (Resources.STOCK_LABEL_OK, 0);
		this.add_button (Resources.STOCK_LABEL_CANCEL, 1);
		this.add_button (Resources.STOCK_LABEL_APPLY, 2);
		this.add_button (Resources.STOCK_LABEL_HELP, 3);

		/*
		 * Initialize widgets
		 */
		scrolled = new Gtk.ScrolledWindow (null, null);
		view = new Gtk.TextView ();
		view.editable = false;
		view.cursor_visible = false;
		view.buffer.text = "Still in development, just an example";
		/*
		 * Dialog layout
		 */
		scrolled.add (view);
		Gtk.Box main_box = this.get_content_area () as Gtk.Box;
		main_box.pack_start (this.scrolled, true, true, 0);
		this.show_all ();

		/*
		 * Connect signals
		 */

	}

	/**
	 * Closes this view.
	 */
	public void on_close (Gtk.Dialog dialog) {
		dialog.destroy ();
	}
}
