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
		this.set_title("Module List");
		this.add_button (Gtk.Stock.OK, 0);
		this.add_button (Gtk.Stock.CANCEL, 1);
		this.add_button (Gtk.Stock.APPLY, 2);
		this.add_button (Gtk.Stock.HELP, 3);

		/*
		 * Dialog layout
		 */

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
