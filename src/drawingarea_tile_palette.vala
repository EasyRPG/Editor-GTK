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
public class TilePaletteDrawingArea : Gtk.DrawingArea {
	private LayerType current_layer;
	private Tileset tileset;

	/**
	 * Builds the tile palette DrawingArea.
	 */
	public TilePaletteDrawingArea () {
		this.add_events(
			Gdk.EventMask.BUTTON_PRESS_MASK |
			Gdk.EventMask.BUTTON1_MOTION_MASK
		);

		this.set_size_request (192, -1);
	}

	/**
	 * Sets a tileset.
	 */
	public void set_tileset (Tileset tileset) {
		this.tileset = tileset;
	}

	/**
	 * Manages the reactions to the layer change.
	 *
	 * Displays the correct palette for the selected layer.
	 */
	public void set_layer (LayerType layer) {
		this.current_layer = layer;

		// Update the DrawingArea size
		switch (layer) {
			case LayerType.LOWER:
				this.set_size_request (
					this.tileset.get_lower_tiles ().get_width () * 2,
					this.tileset.get_lower_tiles ().get_height () * 2
				);
				break;
			case LayerType.UPPER:
			case LayerType.EVENT:
				this.set_size_request (
					this.tileset.get_upper_tiles ().get_width () * 2,
					this.tileset.get_upper_tiles ().get_height () * 2
				);
				break;
			default:
				return;
		}

		// Redraw the DrawingArea
		this.queue_draw ();
	}

	/**
	 * Clears the DrawingArea.
	 */
	public void clear () {
		// Clear the tileset if it was defined
		if (this.tileset != null) {
			this.tileset.clear ();
			this.tileset = null;
		}

		// Make sure it keeps the correct size
		this.set_size_request (192, -1);

		// Redraw the DrawingArea to clean the canvas
		this.queue_draw ();

		// Disable the draw and tile selection events
		this.disable_draw ();
		this.disable_tile_selection ();
	}

	/**
	 * Connects the draw signal and redraws the DrawingArea.
	 */
	public void enable_draw () {
		this.draw.connect (this.on_draw);
	}

	/**
	 * Disconnects the draw signal.
	 */
	public void disable_draw () {
		this.draw.disconnect (this.on_draw);
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

	public bool on_button_press (Gdk.EventButton event) {
		Rect selected_rect = Rect (
			((int) event.x) / 32,
			((int) event.y) / 32,
			1, 1
		);

		this.tileset.set_selected_rect (selected_rect);

		this.queue_draw();
		return true;
	}

	public bool on_button_motion (Gdk.EventMotion event) {
		Rect selected_rect = this.tileset.get_selected_rect ();
		Rect new_rect = selected_rect;

		int dest_x = ((int) event.x) / 32;
		int dest_y = ((int) event.y) / 32;

		new_rect.width = (dest_x - selected_rect.x).abs () + 1;
		new_rect.height = (dest_y - selected_rect.y).abs () + 1;

		if (dest_x < selected_rect.x) {
			new_rect.width = -new_rect.width;
		}

		if (dest_y < selected_rect.y) {
			new_rect.height = -new_rect.height;
		}

		if (new_rect != selected_rect) {
			this.tileset.set_selected_rect (new_rect);
			this.queue_draw ();
		}

		return true;
	}

	/**
	 * Manages the reactions to the draw signal.
	 *
	 * Draws the palette according to the active layer.
	 */
	public bool on_draw (Cairo.Context ctx) {
		// The palette must be scaled to 2x (32x32 tile size)
		ctx.scale (2, 2);

		switch (this.current_layer) {
			case LayerType.LOWER:
				ctx.set_source_surface (this.tileset.get_lower_tiles (), 0, 0);
				break;
			case LayerType.UPPER:
			case LayerType.EVENT:
				ctx.set_source_surface (this.tileset.get_upper_tiles (), 0, 0);
				break;
			default:
				return false;
		}

		// Fast interpolation, similar to nearest-neighbor
		ctx.get_source ().set_filter (Cairo.Filter.FAST);
		ctx.paint ();

		// Selector properties
		ctx.set_source_rgb (1.0,1.0,1.0);
		ctx.set_line_width (1.0);

		Rect selected_rect = this.tileset.get_selected_rect ();
		selected_rect.normalize ();

		ctx.rectangle (
			(double) selected_rect.x * 16,
			(double) selected_rect.y * 16,
			(double) selected_rect.width * 16,
			(double) selected_rect.height * 16
		);

		ctx.stroke ();

		return true;
	}

	/**
	 * Returns tile id for a position in the tileset
	 */
	public static int position_to_id (int x, int y) {
		return y * 6 + x + 1;
	}

	/**
	 * Returns the rectangle of selected tiles.
	 */
	public Rect get_selected_rect () {
		return this.tileset.get_selected_rect ();
	}

	/**
	 * Returns the rectangle of selected tiles prepared
	 * for Drawing to Surfaces.
	 */
	public Rect get_selected_area (int tile_size) {
		return this.tileset.get_selected_area (tile_size);
	}
}
