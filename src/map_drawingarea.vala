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
 * The map DrawingArea.
 */
public class MapDrawingArea : TiledMapDrawingArea, ISelectTiles, IPaintTiles {
	/*
	 * References
	 */
	private TilePaletteDrawingArea palette;

	/*
	 * Schemes
	 */
	public int[,] painted_tiles {get; set; default = null;}

	/*
	 * Surfaces
	 */
	public Cairo.ImageSurface painting_layer_surface {get; set; default = null;}

	/*
	 * Tile selector
	 */
	protected Rect tile_selector {get; set; default = Rect (0, 0, 0, 0);}

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

		// Change the scaled tile size
		switch (scale) {
			case Scale.1_1:
				this.set_scaled_tile_width(32);
				this.set_scaled_tile_height(32);
				break;
			case Scale.1_2:
				this.set_scaled_tile_width(16);
				this.set_scaled_tile_height(16);
				break;
			case Scale.1_4:
				this.set_scaled_tile_width(8);
				this.set_scaled_tile_height(8);
				break;
			case Scale.1_8:
				this.set_scaled_tile_width(4);
				this.set_scaled_tile_height(4);
				break;
			default:
				return;
		}

		// Set a new size for the surfaces
		var visible_rect = get_visible_rect ();
		int surface_width = visible_rect.width * this.get_scaled_tile_width ();
		int surface_height = visible_rect.height * this.get_scaled_tile_height ();

		// Cairo surface instances
		this.lower_layer_surface = new Cairo.ImageSurface (Cairo.Format.RGB24, surface_width, surface_height);
		this.upper_layer_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, surface_width, surface_height);

		// Reset the draw status scheme
		this.draw_status = new bool[this.get_height_in_tiles (), this.get_width_in_tiles ()];

		// Reset the drawn rect
		this.drawn_tiles = Rect (0, 0, 0, 0);

		// Set a new size for the DrawingArea
		int drawing_width = this.get_width_in_tiles () * this.get_scaled_tile_width ();
		int drawing_height = this.get_height_in_tiles () * this.get_scaled_tile_height ();
		this.set_size_request (drawing_width, drawing_height);

		// Redraw the DrawingArea
		this.queue_draw ();
	}

	/**
	 * Clears the MapDrawingArea.
	 */
	public override void clear () {
		// Call the parent clear ()
		base.clear ();

		// Clear surfaces
		this.painting_layer_surface = null;

		// Clear schemes
		this.painted_tiles = {{},{}};

		// Change the size to fluid
		this.set_size_request (-1, -1);

		// Redraw the DrawingArea
		this.queue_draw ();
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
		ctx.save();

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
		int surface_width = this.lower_layer_surface.get_width ();
		int surface_height = this.lower_layer_surface.get_height ();

		// Get the DrawingArea size
		int drawing_width = this.get_allocated_width ();
		int drawing_height = this.get_allocated_height ();

		int x = 0;
		int y = 0;

		// If the visible rect is smaller than the DrawingArea, find where to paint
		if (h_page_size < drawing_width || v_page_size < drawing_height) {
			x = visible_rect.x * this.get_scaled_tile_width ();
			y = visible_rect.y * this.get_scaled_tile_height ();
		}

		// Clear the DrawingArea
		ctx.set_operator (Cairo.Operator.CLEAR);
		ctx.paint ();

		// Set the draw order based in the active layer
		switch (this.get_current_layer ()) {
			case LayerType.LOWER:
				// Paint the lower layer
				ctx.set_source_surface (this.lower_layer_surface, x, y);
				ctx.set_operator (Cairo.Operator.SOURCE);
				ctx.paint ();

				// Blend the drawing layer
				this.draw_painting_layer (
					ctx,
					this.tile_selector.x * this.get_scaled_tile_width (),
					this.tile_selector.y * this.get_scaled_tile_height ()
				);

				// Blend the upper layer with opacity 0.5
				ctx.set_source_surface (this.upper_layer_surface, x, y);
				ctx.set_operator (Cairo.Operator.OVER);
				ctx.paint_with_alpha (0.5);

				// Draw the tile selector
				this.draw_selector (ctx, this.get_scaled_tile_width (), this.get_scaled_tile_height ());
				break;

			case LayerType.UPPER:
				// Paint the lower layer
				ctx.set_source_surface (this.lower_layer_surface, x, y);
				ctx.set_operator (Cairo.Operator.SOURCE);
				ctx.paint ();

				// Paint a black background with opacity 0.5
				ctx.set_source_rgb (0, 0, 0);
				ctx.set_operator (Cairo.Operator.OVER);
				ctx.paint_with_alpha (0.5);

				// We need a new reference for the surface
				// In some cases, a modified version of the upper layer will be used
				Cairo.ImageSurface upper_layer_surface = this.upper_layer_surface;

				// Paint the painting layer if it is defined
				if (this.painting_layer_surface != null) {
					/*
					 * We need to display the upper layer and the tiles in the
					 * drawing layer (a preview of the tiles that will be painted)
					 * without changing anything in the upper layer.
					 */
					upper_layer_surface = new Cairo.ImageSurface (
						Cairo.Format.ARGB32,
						this.upper_layer_surface.get_width (),
						this.upper_layer_surface.get_height ()
					);

					// Copy the current upper layer to this new surface
					var temp_ctx = new Cairo.Context (upper_layer_surface);
					temp_ctx.set_source_surface (this.upper_layer_surface, 0, 0);
					temp_ctx.set_operator (Cairo.Operator.SOURCE);
					temp_ctx.paint ();

					// Blend the drawing layer
					this.draw_painting_layer (
						temp_ctx,
						(this.tile_selector.x - visible_rect.x) * this.get_scaled_tile_width (),
						(this.tile_selector.y - visible_rect.y) * this.get_scaled_tile_height ()
					);
				}

				// Blend the upper layer
				ctx.set_source_surface (upper_layer_surface, x, y);
				ctx.set_operator (Cairo.Operator.OVER);
				ctx.paint ();

				// Draw the tile selector
				this.draw_selector (ctx, this.get_scaled_tile_width (), this.get_scaled_tile_height ());
				break;

			case LayerType.EVENT:
				// Paint the lower layer
				ctx.set_source_surface (this.lower_layer_surface, x, y);
				ctx.set_operator (Cairo.Operator.SOURCE);
				ctx.paint ();

				// Blend the upper layer
				ctx.set_source_surface (this.upper_layer_surface, x, y);
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

					grid_x += this.get_scaled_tile_width ();
				}

				// Add the horizontal lines to the path
				while (grid_y < y + surface_height) {
					ctx.move_to (0, grid_y);
					ctx.line_to (x + surface_width, grid_y);

					grid_y += this.get_scaled_tile_height ();
				}

				// Draw the path with a translucent black and one pixel width
				ctx.set_source_rgba (0, 0, 0, 0.7);
				ctx.set_line_width (1);
				ctx.stroke ();
				break;

			default:
				return false;
		}

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
		if (this.tile_selector == Rect (0, 0, 0, 0)) {
			return false;
		}

		// Disable the left click on event layer
		// TODO: The event layer behaves differently
		if (this.get_current_layer () == LayerType.EVENT) {
			return false;
		}

		switch (this.get_current_drawing_tool ()) {
			case DrawingTool.PEN:
				this.paint_with_pencil (this.palette.tile_selector);
				break;

			default:
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
		if (this.tile_selector == Rect (0, 0, 0, 0)) {
			return false;
		}

		this.apply_painted_tiles (this.get_current_layer ());

		return true;
	}

	/**
	 * Manages the reactions to the leave notify event.
	 */
	public bool on_leave (Gdk.EventCrossing event) {
		// Clear the drawn selector rect
		this.tile_selector = Rect (0, 0, 0, 0);

		// Redraw the DrawingArea
		this.queue_draw ();

		return true;
	}

	/**
	 * Manages the reactions to the motion event.
	 */
	public bool on_motion (Gdk.EventMotion event) {
		int x = ((int) event.x) / this.get_scaled_tile_width ();
		int y = ((int) event.y) / this.get_scaled_tile_height ();

		// Get the selection width and height
		Rect palette_selector = this.palette.tile_selector;
		palette_selector.normalize ();

		int width = palette_selector.width;
		int height = palette_selector.height;

		if (x < 0 || x >= this.get_width_in_tiles () || y < 0 || y >= this.get_height_in_tiles ()) {
			return false;
		}

		Rect new_tile_selector = Rect (x, y, width, height);

		if (new_tile_selector != this.tile_selector) {
			// Update the tile selector
			this.tile_selector = new_tile_selector;

			this.queue_draw ();
		}

		return true;
	}
}
