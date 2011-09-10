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
	private Gtk.ButtonBox dialog_buttons;
	private Gtk.Notebook notebook;
	private Gtk.ListStore actor_list;
	private Gtk.TreeView list_display;
	
	public DataBaseDialog()
	{
		this.set_title("Data Base");
		this.set_size_request (800, 600);

		/* Create Widgets */
		var dialog_buttons = new Gtk.ButtonBox(Gtk.Orientation.HORIZONTAL);
		notebook = new Gtk.Notebook();
		var button_ok = new Gtk.Button.from_stock ("gtk-ok");
		var button_cancel = new Gtk.Button.from_stock ("gtk-cancel");
		var button_apply = new Gtk.Button.from_stock ("gtk-apply");
		var button_help = new Gtk.Button.from_stock ("gtk-help");

		/* Create Containers */
		var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

		/* Do Layaut */
		main_box.pack_start (notebook, true, true, 0);
		main_box.pack_start (dialog_buttons, false, true, 0);
		dialog_buttons.add (button_ok);
		dialog_buttons.add (button_cancel);
		dialog_buttons.add (button_apply);
		dialog_buttons.add (button_help);

		this.add (main_box);
		
		/* Connect actions and widgets */
		button_cancel.clicked.connect(on_cancel);
	}
	private void on_cancel()
	{
		this.destroy();
	}
}