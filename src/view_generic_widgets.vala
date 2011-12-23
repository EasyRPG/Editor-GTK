/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * view_generic_widgets.vala
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
 * This is a generic container that has a list in the left side and sends
 * a signal to the child to actualize everytime a new element of the list
 * is selected
 */
public class IndexSelector : Gtk.Frame {
	/*
	 * Properties
	 */
	private Gtk.ListStore model;
	private Gtk.TreeView view;
	private Gtk.Button button_set_size;
	private Gtk.Box main_box;
	private Gtk.ScrolledWindow scrolled_view;

	/*
	 * Constructor
	 * 
	 * @param title an string with the text displayed on the column header.
	 */
	public IndexSelector (string title) {
		//Create widgets
		this.model = new Gtk.ListStore (1, typeof (string));
		this.view = new Gtk.TreeView ();
		this.button_set_size = new Gtk.Button.with_label ("Max Number ...");
		this.main_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		this.scrolled_view = new Gtk.ScrolledWindow (null, null);
		var list_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		
		//Set properties
		this.view.set_model (model);
		this.view.set_size_request (200, -1);
		this.view.insert_column_with_attributes (-1, title, new Gtk.CellRendererText ());
		this.scrolled_view.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);

		//Do layout
		scrolled_view.add (view);
		list_box.pack_start (scrolled_view, true, true, 0);
		list_box.pack_start (button_set_size, false, true, 0);
		this.main_box.pack_start (list_box, false, true, 10);
		this.add (main_box);

		//TODO: Connect Signals
	}

	/**
	 * Sets the content of the containet witch will be updated when
	 * an item of the list is selected.
	 * 
	 * @param child is the widget to render in the right side of the screen.
	 */
	public void set_child (Gtk.Widget child) {
		main_box.pack_start (child, false, true, 0);
	}
}

/**
 * This is a generic container that is used to display a group of
 * properties on the database dialog.
 */
public class GroupFrame : Gtk.Frame {
	/*
	 * Properties
	 */
	private Gtk.Alignment alignment;
	private Gtk.Box main_box;

	/**
	 * Constructor
	 * 
	 * @param label an string with the label title
	 * @param orientation the orientation for the main container
	 */
	public GroupFrame (string title, Gtk.Orientation orientation = Gtk.Orientation.VERTICAL){
		//Create widgets
		this.set_label (title);
		var label = this.label_widget as Gtk.Label;
		this.main_box = new Gtk.Box (orientation, 0);
		Pango.AttrList attr_list;
		attr_list = new Pango.AttrList ();

		//Set properties
		attr_list.insert (Pango.attr_weight_new (Pango.Weight.BOLD).copy ());
		label.set_attributes (attr_list);

		this.alignment = new Gtk.Alignment (0, 0, 0, 0);
		this.alignment.left_padding = 12;
		this.alignment.bottom_padding = 15;
		this.add (this.alignment);
		this.alignment.add (main_box);
	}


	/**
	 * Add a list of entries to the frame
	 * 
	 * @param labels an array of strings with the labes for the entries
	 * @param entries an array with the widgets to put with the labels
	 */
	public void add_entries (string[] labels, Gtk.Entry[] entries) {
		//Create containers
		var group_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		var labels_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var entries_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

		//Set widgets properties
		labels_box.set_homogeneous (true);
		labels_box.set_size_request (140, -1);
		entries_box.set_size_request (300, -1);

		//Layout labels
		foreach (string title in labels){
			var label = new Gtk.Label (title);
			label.xalign = 0.0f;
			labels_box.pack_start (label, false, true, 0);
		}

		//Layout widgets
		foreach (Gtk.Entry entry in entries){
			entries_box.pack_start(entry, false, true, 2);
		}

		//Do main layout
		group_box.pack_start (labels_box, false, true, 0);
		group_box.pack_start (entries_box, false, true, 0);
		this.main_box.pack_start (group_box, false, true, 0);
	}

	/**
	 * Add a list of spin buttons to the frame
	 * 
	 * @param labels an array of strings with the labes for the entries
	 * @param buttons an array with the widgets to put with the labels
	 */
	public void add_spin_buttons (string[] labels, Gtk.SpinButton[] buttons) {
		//Create containers
		var group_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 20);
		var labels_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var buttons_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

		//Set widgets properties
		labels_box.set_homogeneous (true);
		labels_box.set_size_request (120, -1);
		buttons_box.set_size_request (50, -1);

		//Layout labels
		foreach (string title in labels) {
			var label = new Gtk.Label (title);
			label.xalign = 0.0f;
			labels_box.pack_start (label, false, true, 0);
		}

		//Layout widgets
		foreach (Gtk.SpinButton button in buttons) {
			buttons_box.pack_start (button, false, true, 2);
		}

		//Do main layout
		group_box.pack_start (labels_box, false, true, 0);
		group_box.pack_start (buttons_box, false, true, 0);
		this.main_box.pack_start (group_box, false, true, 0);
	}
	
	/**
	 * Add a list with check buttons
	 * 
	 * @param checks an array with the chech buttons you want to add
	 */
	public void add_check_buttons (Gtk.CheckButton[] checks) {
		//Set Properties
		this.main_box.set_homogeneous (true);

		//Layout widgets
		foreach (Gtk.CheckButton button in checks) {
			button.xalign = 0.0f;
			this.main_box.pack_start (button, false, true, 2);
		}
	}

	/**
	 * Add a customized widget to the frame
	 * 
	 * @param box the box to be added
	 * @param expand bool indicating if box should be expanded
	 * @param fill bool indicating if the box should fill the space
	 * @param paddling the paddling
	 */
	public void add_widget (Gtk.Widget widget, bool expand, bool fill, int paddling) {
		main_box.pack_start (widget, expand, fill, paddling);
	}
}

/**
 * This widget displays an static image with a fixed size
 */
public class ImageFrame : Gtk.AspectFrame {
	/*
	 * Properties
	 */
	private Gtk.DrawingArea view;
	private int width;
	private int height;

	/*
	 * Constructor
	 * 
	 * @param w the width of the display
	 * @param h the heigth of the display
	 */
	public ImageFrame (int w, int h) {
		//Create widgets
		this.view = new Gtk.DrawingArea ();
		this.width = w;
		this.height = h;
		
		//Set properties
		this.view.set_size_request (this.width, this.height);

		//Do layout
		this.add (view);
	}

	/**
	 * Loads an image from a file and draws a rect starting from the selected
	 * position and with the DrawingArea size
	 * 
	 * @param image_path an string with the image file path
	 * @param x an int indicating witch column should blitting start from
	 * @param y an int indicating witch row should blitting start from
	 */
	public void render(string image_path, int x, int y) {
		//TODO: use cairo to blit the file content.
	}
}

/**
 * This widget displays an animated image with a fixed size
 */
public class AnimatedFrame : Gtk.AspectFrame {
	/*
	 * Properties
	 */
	private Gtk.DrawingArea view;
	private int width;
	private int height;
//	private int[] frames; //FIXME: not actually int, but an array with the images to be displayed sequencelly

	/*
	 * Constructor
	 * 
	 * @param w the width of the display
	 * @param h the heigth of the display
	 */
	public AnimatedFrame (int w, int h){
		//Create widgets
		this.view = new Gtk.DrawingArea();
		this.width = w;
		this.height = h;
		
		//Set properties
		this.view.set_size_request(this.width, this.height);

		//Do layout
		this.add(view);
	}

	/**
	 * Render the frame to be displayed
	 * Returns the image with the frame
	 * 
	 * @param source an image to blit from
	 * @param x an int indicating witch column should blitting start from
	 * @param y an int indicating witch row should blitting start from
	 */
/*	private int render_frame (string source, int x, int y) {
		//TODO: use cairo to blit the file content.
		//FIXME: change string for a reference to the base image to get the frames from.
		return 0;
	}*/
}