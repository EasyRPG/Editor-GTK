/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * drawingarea_map.vala
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
 * The map DrawingArea.
 */
public class MapDrawingArea : TiledMapDrawingArea {
	// References
	private TilePaletteDrawingArea palette;

	// Selector
	protected Rect drawn_selector;

	/**
	 * Builds the map DrawingArea.
	 */
	public MapDrawingArea (Gtk.ScrolledWindow scrolled_window, TilePaletteDrawingArea palette) {
		// TiledMapDrawingArea constructor
		base (scrolled_window);

		this.palette = palette;

		// Set the event mask
		this.add_events (
			Gdk.EventMask.LEAVE_NOTIFY_MASK|
			Gdk.EventMask.POINTER_MOTION_MASK|
			Gdk.EventMask.BUTTON1_MOTION_MASK|
			Gdk.EventMask.BUTTON_PRESS_MASK|
			Gdk.EventMask.BUTTON_RELEASE_MASK
		);
	}

	/**
	 * Sets the current layer.
	 *
	 * The maprender will change the displayed content according to the current layer.
	 */
	public override void set_current_layer (LayerType layer) {
		base.set_current_layer (layer);

		// Redraw the DrawingArea
		this.queue_draw ();
	}

	/**
	 * Sets the current scale.
	 *
	 * The maprender will change the size of the displayed tiles according to the current scale.
	 */
	public override void set_current_scale (Scale scale) {
		base.set_current_scale (scale);

		// Clear the surfaces
		this.clear_surfaces ();

		// Change the tile size
		switch (scale) {
			case Scale.1_1:
				this.tile_size = 32;
				break;
			case Scale.1_2:
				this.tile_size = 16;
				break;
			case Scale.1_4:
				this.tile_size = 8;
				break;
			case Scale.1_8:
				this.tile_size = 4;
				break;
			default:
				return;
		}

		// Set a new size for the surfaces
		var visible_rect = get_visible_rect ();
		int surface_width = visible_rect.width * this.tile_size;
		int surface_height = visible_rect.height * this.tile_size;

		// Cairo surface instances
		this.surface_lower_layer = new Cairo.ImageSurface (Cairo.Format.RGB24, surface_width, surface_height);
		this.surface_upper_layer = new Cairo.ImageSurface (Cairo.Format.ARGB32, surface_width, surface_height);

		// Reset the draw status scheme
		this.draw_status = new bool[this.height_in_tiles, this.width_in_tiles];

		// Reset the drawn rect
		this.drawn_tiles = Rect (0, 0, 0, 0);

		// Set a new size for the DrawingArea
		int drawing_width = this.width_in_tiles * this.tile_size;
		int drawing_height = this.height_in_tiles * this.tile_size;
		this.set_size_request (drawing_width, drawing_height);

		// Redraw the DrawingArea
		this.queue_draw ();
	}

	/**
	 * Clears the DrawingArea.
	 */
	public override void clear () {
		base.clear ();

		// Change the size to fluid
		this.set_size_request (-1, -1);

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
		this.leave_notify_event.connect (this.on_leave);
		this.motion_notify_event.connect (this.on_motion);
		this.button_press_event.connect (this.on_button_pressed);
		this.button_release_event.connect (this.on_button_released);
	}

	/**
	 * Disconnects the tile selection events.
	 */
	public void disable_tile_selection () {
		this.leave_notify_event.disconnect (this.on_leave);
		this.motion_notify_event.disconnect (this.on_motion);
		this.button_release_event.disconnect (this.on_button_released);
		this.button_press_event.disconnect (this.on_button_pressed);
	}

	/**
	 * Manages the reactions to the draw signal.
	 *
	 * Draws the map according to the active layer and scale.
	 */
	public override bool on_draw (Cairo.Context ctx) {
		// Get the visible rect
		var visible_rect = this.get_visible_rect ();

		// If the visible rect is different from the already drawn rect
		if (visible_rect != this.drawn_tiles) {
			// Update the surfaces and do selective cleaning and drawing
			this.update_surfaces (visible_rect);
			this.clean_surfaces (visible_rect);
			this.draw_surfaces (visible_rect);

			// Update the drawn tiles rect
			this.drawn_tiles.set_values (
				visible_rect.x, visible_rect.y,
				visible_rect.width, visible_rect.height
			);
		}

		// Get the adjustment values
		var hadjustment = this.scrolled_window.get_hadjustment ();
		var vadjustment = this.scrolled_window.get_vadjustment ();

		int h_page_size = (int) hadjustment.get_page_size ();
		int v_page_size = (int) vadjustment.get_page_size ();

		// Get the surfaces size
		int surface_width = this.surface_lower_layer.get_width ();
		int surface_height = this.surface_lower_layer.get_height ();

		// Get the DrawingArea size
		int drawing_width = this.get_allocated_width ();
		int drawing_height = this.get_allocated_height ();

		int x = 0;
		int y = 0;

		// If the visible rect is smaller than the DrawingArea, find where to paint
		if (h_page_size < drawing_width || v_page_size < drawing_height) {
			x = visible_rect.x * this.tile_size;
			y = visible_rect.y * this.tile_size;
		}

		// Clear the DrawingArea
		ctx.set_operator (Cairo.Operator.CLEAR);
		ctx.paint ();

		// Set the draw order based in the active layer
		switch (this.get_current_layer ()) {
			case LayerType.LOWER:
				// Paint the lower layer
				ctx.set_source_surface (this.surface_lower_layer, x, y);
				ctx.set_operator (Cairo.Operator.SOURCE);
				ctx.paint ();

				// Blend the upper layer with opacity 0.5
				ctx.set_source_surface (this.surface_upper_layer, x, y);
				ctx.set_operator (Cairo.Operator.OVER);
				ctx.paint_with_alpha (0.5);
				break;

			case LayerType.UPPER:
				// Paint the lower layer
				ctx.set_source_surface (this.surface_lower_layer, x, y);
				ctx.set_operator (Cairo.Operator.SOURCE);
				ctx.paint ();

				// Paint a black background with opacity 0.5
				ctx.set_source_rgb (0, 0, 0);
				ctx.set_operator (Cairo.Operator.OVER);
				ctx.paint_with_alpha (0.5);

				// Blend the upper layer
				ctx.set_source_surface (this.surface_upper_layer, x, y);
				ctx.set_operator (Cairo.Operator.OVER);
				ctx.paint ();
				break;

			case LayerType.EVENT:
				// Paint the lower layer
				ctx.set_source_surface (this.surface_lower_layer, x, y);
				ctx.set_operator (Cairo.Operator.SOURCE);
				ctx.paint ();

				// Blend the upper layer
				ctx.set_source_surface (this.surface_upper_layer, x, y);
				ctx.set_operator (Cairo.Operator.OVER);
				ctx.paint ();

				// Restore the context to the initial state (default scale)
				ctx.restore ();

				/*
				 * The grid starting point.
				 * The 0.5 pixel correction prevents blurry lines.
				 */
				double grid_x = x - 0.5;
				double grid_y = y - 0.5;

				// Add the vertical lines to the path
				while (grid_x < x + surface_width) {
					ctx.move_to (grid_x, 0);
					ctx.line_to (grid_x, y + surface_height);

					grid_x += this.tile_size;
				}

				// Add the horizontal lines to the path
				while (grid_y < y + surface_height) {
					ctx.move_to (0, grid_y);
					ctx.line_to (x + surface_width, grid_y);

					grid_y += this.tile_size;
				}

				// Draw the path with a translucent black and one pixel width
				ctx.set_source_rgba (0, 0, 0, 0.7);
				ctx.set_line_width (1);
				ctx.stroke ();
				break;

			default:
				return false;
		}

		this.draw_selector (ctx);

		return true;
	}

	/**
	 * Draws the tile selector.
	 */
	public bool draw_selector (Cairo.Context ctx) {
		// If the selection is empty, stop the process
		if (this.drawn_selector == Rect (0, 0, 0, 0)) {
			return false;
		}

		ctx.set_source_rgb (1.0,1.0,1.0);
		ctx.set_line_width (2.0);
		ctx.rectangle (
			this.drawn_selector.x * tile_size,
			this.drawn_selector.y * tile_size,
			this.drawn_selector.width * tile_size,
			this.drawn_selector.height * tile_size
		);

		ctx.stroke ();

		return true;
	}

	/**
	 * Manages the reactions to button press signals.
	 */
	public bool on_button_pressed (Gdk.EventButton event) {
		switch (event.button) {
			case 1:
				return this.on_left_click (event);

			case 3:
				return this.on_right_click (event);

			default:
				return false;
		}
	}

	/**
	 * Manages the reactions to a "left click" event.
	 */
	public bool on_left_click (Gdk.EventButton event) {
		// If the selection is empty, stop the process
		if (this.drawn_selector == Rect (0, 0, 0, 0)) {
			return false;
		}

		// Disable the left click on event layer
		// TODO: The event layer behaves differently
		if (this.get_current_layer () == LayerType.EVENT) {
			return false;
		}

		return true;
	}

	/**
	 * Manages the reactions to a "right click" event.
	 */
	public bool on_right_click (Gdk.EventButton event) {
		return false;
	}

	/**
	 * Manages the reactions to button release signals.
	 */
	public bool on_button_released (Gdk.EventButton event) {
		switch (event.button) {
			case 1:
				return this.on_left_click_released (event);

			default:
				return false;
		}
	}

	/**
	 * Manages the reactions to a "left click" release event.
	 */
	public bool on_left_click_released (Gdk.EventButton event) {
		// If the selection is empty, stop the process
		if (this.drawn_selector == Rect (0, 0, 0, 0)) {
			return false;
		}

		return true;
	}

	/**
	 * Manages the reactions to the leave notify event.
	 */
	public bool on_leave (Gdk.EventCrossing event) {
		// Clear the drawn selector rect
		this.drawn_selector = Rect (0, 0, 0, 0);

		// Redraw the DrawingArea
		this.queue_draw ();

		return true;
	}

	/**
	 * Manages the reactions to the motion event.
	 */
	public bool on_motion (Gdk.EventMotion event) {
		int x = ((int) event.x) / this.tile_size;
		int y = ((int) event.y) / this.tile_size;

		// Get the selection width and height
		Rect tileset_selector = this.palette.tile_selector;
		tileset_selector.normalize ();

		int width = tileset_selector.width;
		int height = tileset_selector.height;

		if (x < 0 || x >= this.width_in_tiles || y < 0 || y >= this.height_in_tiles) {
			return false;
		}

		Rect visible_selector_rect = Rect (x, y, width, height);

		if (visible_selector_rect != this.drawn_selector) {
			// Update the drawn selector rect
			this.drawn_selector = visible_selector_rect;

			this.queue_draw ();
		}

		return true;
	}
}