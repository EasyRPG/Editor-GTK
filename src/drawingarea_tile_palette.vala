/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * drawingarea_tile_palette.vala
 * Copyright (C) EasyRPG Project 2011-2012
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
 * The tile palette DrawingArea.
 */
public class TilePaletteDrawingArea : TiledDrawingArea, ISelectTiles {
	// Surface
	protected Cairo.ImageSurface surface_tiles;

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
		this.surface_tiles = this.tileset.get_layer_tiles (layer);

		// If the returned surface is null, stop the process
		if (this.surface_tiles == null) {
			return;
		}

		// Resize the DrawingArea to match the size of the surface
		this.set_size_request (
			this.surface_tiles.get_width () * 2,
			this.surface_tiles.get_height () * 2
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

		// Disable the draw and tile selection events
		this.disable_draw ();
		this.disable_tile_selection ();
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
		if (this.surface_tiles == null) {
			return false;
		}

		// The palette must be scaled to 2x (32x32 tile size)
		ctx.scale (2, 2);
		ctx.set_source_surface (this.surface_tiles, 0, 0);

		// Fast interpolation, similar to nearest-neighbor
		ctx.get_source ().set_filter (Cairo.Filter.FAST);
		ctx.paint ();

		// Draw the tile selector
		this.draw_selector (ctx, 16);

		return true;
	}
}