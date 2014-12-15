/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * Copyright (C) 2012 EasyRPG Project
 *
 * License: https://github.com/EasyRPG/Editor/blob/master/COPYING GPL
 *
 * Authors:
 * - Sebastian Reichel (sre) <sre@ring0.de>
 * - Francisco de la Peña (fdelapena) <fran@fran.cr>
 */

/**
 * The map shift window view.
 */
public class MapShiftDialog : Gtk.Dialog {
	public Direction dir {get; private set; default = Direction.UP;}
	public int amount {get; private set; default = 1;}

	private Gtk.ToggleButton button_up;
	private Gtk.ToggleButton button_down;
	private Gtk.ToggleButton button_left;
	private Gtk.ToggleButton button_right;

	/**
	 * Builds the map shift window.
	 */
	public MapShiftDialog () {
		Gtk.Box main_box = this.get_content_area () as Gtk.Box;

		/* Init dialog */
		this.set_title("Map Shift");
		this.add_button (Resources.STOCK_LABEL_CANCEL, Gtk.ResponseType.CANCEL);
		this.add_button (Resources.STOCK_LABEL_OK, Gtk.ResponseType.OK);

		/* Init window's elements */
		var hbox         = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
		var input_amount = new Gtk.SpinButton.with_range(1.0,500.0,1.0);
		var frame_amount = new Gtk.Frame ("Number of Units");
		var frame_dir    = new Gtk.Frame ("Direction");
		var grid_dir    = new Gtk.Grid ();
		button_up    = new Gtk.ToggleButton ();
		button_down  = new Gtk.ToggleButton ();
		button_left  = new Gtk.ToggleButton ();
		button_right = new Gtk.ToggleButton ();

		/* load button images */
		button_up.add (new Gtk.Image.from_stock (Resources.STOCK_ICON_GO_UP, Gtk.IconSize.BUTTON));
		button_down.add (new Gtk.Image.from_stock (Resources.STOCK_ICON_GO_DOWN, Gtk.IconSize.BUTTON));
		button_left.add (new Gtk.Image.from_stock (Resources.STOCK_ICON_GO_BACK, Gtk.IconSize.BUTTON));
		button_right.add (new Gtk.Image.from_stock (Resources.STOCK_ICON_GO_FORWARD, Gtk.IconSize.BUTTON));

		/* set inital button state */
		updateDirection(this.dir);

		/* Dialog Layout */
		hbox.pack_start (frame_dir,    true, true, 0);
		hbox.pack_start (frame_amount, true, true, 0);

		frame_dir.add (grid_dir);
		frame_amount.add (input_amount);

		grid_dir.attach (button_up, 1, 0, 1, 1);
		grid_dir.attach (button_left, 0, 1, 1, 1);
		grid_dir.attach (button_right, 2, 1, 1, 1);
		grid_dir.attach (button_down, 1, 2, 1, 1);
		button_up.expand = true;
		button_left.expand = true;
		button_right.expand = true;
		button_down.expand = true;

		main_box.pack_start (hbox, true, true, 0);

		button_up.toggled.connect(() => {updateDirection(Direction.UP);});
		button_down.toggled.connect(() => {updateDirection(Direction.DOWN);});
		button_left.toggled.connect(() => {updateDirection(Direction.LEFT);});
		button_right.toggled.connect(() => {updateDirection(Direction.RIGHT);});

		input_amount.value_changed.connect(() => {
			this.amount = input_amount.get_value_as_int ();
		});

		this.show_all ();
	}

	private void updateDirection(Direction dir) {
		/* ignore button toggles produced by the following code */
		if(this.dir != Direction.NONE) {
			this.dir = Direction.NONE;

			button_up.active    = (dir == Direction.UP);
			button_down.active  = (dir == Direction.DOWN);
			button_left.active  = (dir == Direction.LEFT);
			button_right.active = (dir == Direction.RIGHT);
			this.dir = dir;
		}
	}
}
