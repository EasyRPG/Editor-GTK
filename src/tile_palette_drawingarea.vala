/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * Copyright (C) 2011-2013 EasyRPG Project
 *
 * License: https://github.com/EasyRPG/Editor/blob/master/COPYING GPL
 *
 * Authors:
 * - Aitor García (Falc) <aitor.falc@gmail.com>
 * - Sebastian Reichel (sre) <sre@ring0.de>
 */

/**
 * The tile palette DrawingArea.
 */
public class TilePaletteDrawingArea : TiledDrawingArea, ISelectTiles {
	/*
	 * References
	 */
	public AbstractImageset? lower_layer_imageset {get; set; default = null;}
	public AbstractImageset? upper_layer_imageset {get; set; default = null;}

	// Surface
	protected Cairo.ImageSurface palette_surface;

	// Tile selector
	protected Rect tile_selector {get; set; default = Rect (0, 0, 0, 0);}

	/**
	 * Builds the tile palette DrawingArea.
	 */
	public TilePaletteDrawingArea () {
		// Set the event mask
		this.add_events(
			Gdk.EventMask.BUTTON_PRESS_MASK|
			Gdk.EventMask.BUTTON1_MOTION_MASK
		);

		this.set_size_request (192, -1);
	}

	/**
	 * Displays a set of tiles.
	 */
	public void load_tiles (LayerType layer) {
		if (layer == LayerType.LOWER) {
			this.palette_surface = this.lower_layer_imageset.get_imageset_surface ();
		}
		else {
			this.palette_surface = this.upper_layer_imageset.get_imageset_surface ();
		}

		// If the returned surface is null, stop the process
		if (this.palette_surface == null) {
			return;
		}

		// Resize the DrawingArea to match the size of the surface
		this.set_size_request (
			this.palette_surface.get_width () * 2,
			this.palette_surface.get_height () * 2
		);

		// Redraw the DrawingArea
		this.queue_draw ();
	}

	/**
	 * Clears the DrawingArea.
	 */
	public override void clear () {
		base.clear ();

		// Make sure it keeps the correct size
		this.set_size_request (192, -1);

		// Redraw the DrawingArea
		this.queue_draw ();
	}

	/**
	 * Connects the tile selection events.
	 */
	public void enable_tile_selection () {
		this.button_press_event.connect (this.on_button_press);
		this.motion_notify_event.connect (this.on_button_motion);
	}

	/**
	 * Disconnects the tile selection events.
	 */
	public void disable_tile_selection () {
		this.button_press_event.disconnect (this.on_button_press);
		this.motion_notify_event.disconnect (this.on_button_motion);
		this.clear_selector ();
	}

	/**
	 * Manages the reactions to button press signals.
	 */
	public bool on_button_press (Gdk.EventButton event) {
		switch (event.button) {
			case 1:
				return this.on_left_click (event);

			default:
				return false;
		}
	}

	/**
	 * Manages the reactions to a "left click" event.
	 */
	public bool on_left_click (Gdk.EventButton event) {
		// Update the selector
		this.tile_selector = Rect (
			((int) event.x) / 32,
			((int) event.y) / 32,
			1, 1
		);

		// Redraw the DrawingArea
		this.queue_draw();

		return true;
	}

	public bool on_button_motion (Gdk.EventMotion event) {
		Rect new_tile_selector = this.tile_selector;

		int dest_x = ((int) event.x) / 32;
		int dest_y = ((int) event.y) / 32;

		new_tile_selector.width = (dest_x - this.tile_selector.x).abs () + 1;
		new_tile_selector.height = (dest_y - this.tile_selector.y).abs () + 1;

		if (dest_x < this.tile_selector.x) {
			new_tile_selector.width = -new_tile_selector.width;
		}

		if (dest_y < this.tile_selector.y) {
			new_tile_selector.height = -new_tile_selector.height;
		}

		// If the tile selector changed, update it
		if (new_tile_selector != this.tile_selector) {
			this.tile_selector = new_tile_selector;

			// Redraw the DrawingArea
			this.queue_draw ();
		}

		return true;
	}

	/**
	 * Manages the reactions to the draw signal.
	 *
	 * Draws the palette according to the active layer.
	 */
	public override bool on_draw (Cairo.Context ctx) {
		// If the surface is null, stop the process
		if (this.palette_surface == null) {
			return false;
		}

		// Save the context initial state
		ctx.save();

		// The palette must be scaled to 2x (32x32 tile size)
		ctx.scale (2, 2);
		ctx.set_source_surface (this.palette_surface, 0, 0);

		// Fast interpolation, similar to nearest-neighbor
		ctx.get_source ().set_filter (Cairo.Filter.FAST);
		ctx.paint ();

		// Restore the context state
		ctx.restore ();

		// Draw the tile selector
		this.draw_selector (ctx, 32, 32);

		return true;
	}
}
