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
public class MapDrawingArea : Gtk.DrawingArea {
	private weak Gtk.ScrolledWindow scrolled_window;
	private TilePaletteDrawingArea palette;
	private int tile_width;
	private int tile_height;
	private int tile_size;
	private int[,] lower_layer;
	private int[,] upper_layer;
	private bool[,] draw_status;
	private Cairo.ImageSurface surface_lower_layer;
	private Cairo.ImageSurface surface_upper_layer;
	private LayerType current_layer;
	private Scale current_scale;
	private Rect drawn_rect;
	private int cursor_x;
	private int cursor_y;

	/**
	 * Builds the map DrawingArea.
	 */
	public MapDrawingArea (Gtk.ScrolledWindow scrolled_window, TilePaletteDrawingArea palette) {
		this.scrolled_window = scrolled_window;
		this.palette = palette;
		this.set_size_request (-1, -1);
		this.set_halign (Gtk.Align.CENTER);
		this.set_valign (Gtk.Align.CENTER);
		this.add_events(Gdk.EventMask.POINTER_MOTION_MASK);
	}

	/**
	 * Loads the map.
	 * 
	 * Gets the layer schemes and reads them to draw the tiles in each layer surface.
	 */
	public void load_map_scheme (int[,] lower_layer, int[,] upper_layer) {
		this.lower_layer = lower_layer;
		this.upper_layer = upper_layer;

		// Map width and height (in tiles) 
		this.tile_width = this.lower_layer.length[1];
		this.tile_height = this.lower_layer.length[0];

		this.draw.connect (on_draw);
		this.motion_notify_event.connect (on_motion);
	}

	/**
	 * Manages the reactions to the layer change.
	 */
	public void set_layer (LayerType layer) {
		this.current_layer = layer;

		// Redraw the DrawingArea
		this.queue_draw ();
	}

	/**
	 * Manages the reactions to the scale change.
	 * 
	 * Updates the DrawingArea size based in the selected scale.
	 */
	public void set_scale (Scale scale) {
		this.current_scale = scale;

		// Clear the surfaces
		this.surface_lower_layer = null;
		this.surface_upper_layer = null;

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
		this.draw_status = new bool[this.tile_height, this.tile_width];

		// Reset the drawn rect
		this.drawn_rect = Rect (0, 0, 0, 0);

		// Set a new size for the DrawingArea
		int drawing_width = this.tile_width * this.tile_size;
		int drawing_height = this.tile_height * this.tile_size;
		this.set_size_request (drawing_width, drawing_height);

		// Redraw the DrawingArea
		this.queue_draw ();
	}

	/**
	 * Clears the DrawingArea.
	 */
	public void clear () {
		// Clear the surfaces
		this.surface_lower_layer = null;
		this.surface_upper_layer = null;

		// Clear the schemes
		this.lower_layer = {{},{}};
		this.upper_layer = {{},{}};
		this.draw_status = {{},{}};

		// Change the size to fluid
		this.set_size_request (-1, -1);

		// Redraw the DrawingArea and don't react anymore to the draw signal
		this.queue_draw ();
		this.draw.disconnect (on_draw);
		this.motion_notify_event.connect (on_motion);
	}

	/**
	 * Gets the visible rect.
	 * 
	 * Uses the scrollbars position and page size to find which tiles
	 * should be drawn on the DrawingArea.
	 */
	private Rect get_visible_rect () {
		var visible_rect = Rect (0, 0, this.tile_width, this.tile_height);

		// Get the adjustment values
		var hadjustment = this.scrolled_window.get_hadjustment ();
		var vadjustment = this.scrolled_window.get_vadjustment ();

		int h_page_size = (int) hadjustment.get_page_size ();
		int h_value = (int) hadjustment.get_value ();
		int v_page_size = (int) vadjustment.get_page_size ();
		int v_value = (int) vadjustment.get_value ();

		// Get the DrawingArea size
		int drawing_width = this.get_allocated_width ();
		int drawing_height = this.get_allocated_height ();

		// Find the visible rect, if displaying only a part of the DrawingArea 
		if (h_page_size < drawing_width || v_page_size < drawing_height) {
			// Coordinates of the top-left tile to be drawn (first one)
			int first_x = (int) (h_value / this.tile_size);
			int first_y = (int) (v_value / this.tile_size);

			// Coordinates of the bottom-right tile to be drawn (last one)
			int last_x = (int) ((h_value + h_page_size) / this.tile_size);
			int last_y = (int) ((v_value + v_page_size) / this.tile_size);

			if (last_x > this.tile_width - 1) {
				last_x = this.tile_width - 1;
			}

			if (last_y > this.tile_height - 1) {
				last_y = this.tile_height - 1;
			}

			int width = (last_x - first_x) + 1;
			int height = (last_y - first_y) + 1;

			visible_rect.set_values (first_x, first_y, width, height);
		}

		return visible_rect;
	}

	/**
	 * Updates the layer surfaces.
	 * 
	 * Creates new surfaces with a size determined by the visible rect and
	 * copies the already drawn tiles, changing their positions if needed.
	 */
	private void update_surfaces (Rect visible_rect) {
		// New references for the layer surfaces 
		var old_lower_layer = this.surface_lower_layer;
		var old_upper_layer = this.surface_upper_layer;

		// Set a new size for the surfaces
		int surface_width = visible_rect.width * this.tile_size;
		int surface_height = visible_rect.height * this.tile_size;

		// Create new surfaces
		this.surface_lower_layer = new Cairo.ImageSurface (Cairo.Format.RGB24, surface_width, surface_height);
		this.surface_upper_layer = new Cairo.ImageSurface (Cairo.Format.ARGB32, surface_width, surface_height);

		// Find how many tiles should be shifted to the right and bottom 
		int offset_x = (this.drawn_rect.x - visible_rect.x) * this.tile_size;
		int offset_y = (this.drawn_rect.y - visible_rect.y) * this.tile_size;

		// Draw the tiles
		var ctx = new Cairo.Context (this.surface_lower_layer);
		ctx.set_source_surface (old_lower_layer, offset_x, offset_y);
		ctx.paint ();

		ctx = new Cairo.Context (this.surface_upper_layer);
		ctx.set_source_surface (old_upper_layer, offset_x, offset_y);
		ctx.paint ();
	}

	/**
	 * Cleans the surfaces removing the tiles that are not displayed anymore
	 * in the DrawingArea, determined by the visible rect.
	 */
	private void clean_surfaces (Rect visible) {
		var drawn = this.drawn_rect;

		// If the drawn tiles rect is not defined, stop the process
		if (drawn == Rect (0, 0, 0, 0)) {
			return;
		}

		/*
		 * Clean the drawn tiles rect if the visible rect does not need to keep
		 * any drawn tile, and stop the process.
		 */
		if (!drawn.overlaps (visible)) {
			this.clean_tiles_rect (Rect (drawn.x, drawn.y, drawn.width, drawn.height));
			return;
		}

		int first_x = 0;
		int first_y = 0;
		int width = 0;
		int height = 0;

		/*
		 * If visible rect's left edge is to the right of drawn rect's left
		 * edge, clean those tiles on the left.
		 */
		if (visible.x > drawn.x) {
			first_x = drawn.x;
			first_y = drawn.y;
			width = visible.x - drawn.x;
			height = drawn.height;

			this.clean_tiles_rect (Rect (first_x, first_y, width, height));
		}

		/*
		 * If visible rect's right edge is to the left of drawn rect's right
		 * edge, clean those tiles on the right.
		 */
		if (visible.x + visible.width < drawn.x + drawn.width) {
			first_x = visible.x + visible.width;
			first_y = drawn.y;
			width = (drawn.x + drawn.width) - first_x;
			height = drawn.height;

			this.clean_tiles_rect (Rect (first_x, first_y, width, height));
		}

		/*
		 * If visible rect's top edge is below drawn rect's top edge, clean
		 * those upper tiles.
		 */
		if (visible.y > drawn.y) {
			first_x = drawn.x;
			first_y = drawn.y;
			width = drawn.width;
			height = visible.y - drawn.y;

			this.clean_tiles_rect (Rect (first_x, first_y, width, height));
		}

		/*
		 * If visible rect's bottom edge is above drawn rect's bottom edge,
		 * clean those lower tiles.
		 */
		if (visible.y + visible.height < drawn.y + drawn.height) {
			first_x = drawn.x;
			first_y = visible.y + visible.height;
			width = drawn.width;
			height = (drawn.y + drawn.height) - first_y;

			this.clean_tiles_rect (Rect (first_x, first_y, width, height));
		}
	}

	/**
	 * Cleans the tiles contained in a rect.
	 */
	private void clean_tiles_rect (Rect rect) {
		int col = rect.x;
		int row = rect.y;

		while (row < rect.y + rect.height) {
			bool is_drawn = this.draw_status[row, col];

			// If drawn, mark as not drawn
			if (is_drawn) {
				this.draw_status[row, col] = false;
			}

			col++;

			// Advance to the next row when cleaning is complete for this row 
			if (col == rect.x + rect.width) {
				col = rect.x;
				row++;
			}
		}
	}

	/**
	 * Draws the tiles that will be displayed in the DrawingArea, determined
	 * by the visible rect.
	 */
	private void draw_surfaces (Rect visible) {
		var drawn = this.drawn_rect;

		/*
		 * If the drawn tiles rect is not defined, or the visible rect does not
		 * keep older tiles, draw all of them and stop the process.
		 */
		if (drawn == Rect (0, 0, 0, 0) || !drawn.overlaps (visible)) {
			this.draw_tiles_rect (visible);
			return;
		}

		int first_x = 0;
		int first_y = 0;
		int width = 0;
		int height = 0;

		int dest_x = 0;
		int dest_y = 0;

		/*
		 * If visible rect's left edge is to the left of drawn rect's left
		 * edge, draw only the tiles on the left.
		 */
		if (visible.x < drawn.x) {
			first_x = visible.x;
			first_y = visible.y;
			width = drawn.x - visible.x;
			height = visible.height;

			// The tiles will be drawn on the left side of the surfaces
			dest_x = 0;
			dest_y = 0;

			this.draw_tiles_rect (Rect (first_x, first_y, width, height), dest_x, dest_y);
		}

		/*
		 * If visible rect's right edge is to the right of drawn rect's right
		 * edge, draw only the tiles on the right.
		 */
		if (visible.x + visible.width > drawn.x + drawn.width) {
			first_x = drawn.x + drawn.width;
			first_y = visible.y;
			width = (visible.x + visible.width) - first_x;
			height = visible.height;

			// The tiles will be drawn on the right side of the surfaces
			dest_x = visible.width - width;
			dest_y = 0;

			this.draw_tiles_rect (Rect (first_x, first_y, width, height), dest_x, dest_y);
		}

		/*
		 * If visible rect's top edge is above drawn rect's top edge, draw only
		 * those upper tiles.
		 */
		if (visible.y < drawn.y) {
			first_x = visible.x;
			first_y = visible.y;
			width = visible.width;
			height = drawn.y - visible.y;

			// The tiles will be drawn on the upper side of the surfaces
			dest_x = 0;
			dest_y = 0;

			this.draw_tiles_rect (Rect (first_x, first_y, width, height), dest_x, dest_y);
		}

		/*
		 * If visible rect's bottom edge is below drawn rect's bottom edge, draw
		 * only those lower tiles.
		 */
		if (visible.y + visible.height > drawn.y + drawn.height) {
			first_x = visible.x;
			first_y = drawn.y + drawn.height;
			width = visible.width;
			height = (visible.y + visible.height) - first_y;

			// The tiles will be drawn on the lower side of the surfaces
			dest_x = 0;
			dest_y = visible.height - height;

			this.draw_tiles_rect (Rect (first_x, first_y, width, height), dest_x, dest_y);
		}
	}

	/**
	 * Draws the tiles contained in a rect.
	 */
	private void draw_tiles_rect (Rect rect, int dest_x = 0, int dest_y = 0) {
		int col = 0;
		int row = 0;

		while (row < rect.height) {
			bool is_drawn = this.draw_status[rect.y + row, rect.x + col];

			// Draw the tile if not already drawn
			if (!is_drawn) {
				// Get the tile ids
				int lower_tile_id = this.lower_layer[rect.y + row, rect.x + col];
				int upper_tile_id = this.upper_layer[rect.y + row, rect.x + col];

				// Get and draw the lower layer tile, if any
				if (lower_tile_id != 0) {
					var surface_tile = this.palette.get_tile (lower_tile_id, LayerType.LOWER);
					// The standard 16x16 tile size is used because of the use of scale ()
					this.draw_tile (surface_tile, this.surface_lower_layer, (dest_x + col) * 16, (dest_y + row) * 16);
				}

				// Get and draw the upper layer tile, if any
				if (upper_tile_id != 0) {
					var surface_tile = this.palette.get_tile (upper_tile_id, LayerType.UPPER);
					// The standard 16x16 tile size is used because of the use of scale ()
					this.draw_tile (surface_tile, this.surface_upper_layer, (dest_x + col) * 16, (dest_y + row) * 16);
				}

				// Mark the tile as drawn
				this.draw_status[rect.y + row, rect.x + col] = true;
			}

			col++;

			// Advance to the next row when drawing is complete for this row 
			if (col == rect.width) {
				col = 0;
				row++;
			}
		}
	}

	/**
	 * Draws a tile on a surface.
	 */
	private void draw_tile (Cairo.ImageSurface tile, Cairo.ImageSurface surface, int x, int y) {
		var ctx = new Cairo.Context (surface);

		// Sets the correct scale factor
		switch (this.current_scale) {
			case Scale.1_1:
				ctx.scale (2, 2);
				break;
			case Scale.1_2:
				ctx.scale (1, 1);
				break;
			case Scale.1_4:
				ctx.scale (0.5, 0.5);
				break;
			case Scale.1_8:
				ctx.scale (0.25, 0.25);
				break;
		}

		// Draws the tile on (x,y)
		ctx.rectangle (x, y, 16, 16);
		ctx.set_source_surface (tile, x, y);
		ctx.get_source ().set_filter (Cairo.Filter.FAST);
		ctx.set_operator (Cairo.Operator.SOURCE);

		ctx.fill ();
	}

	/**
	 * Manages the reactions to the draw signal.
	 * 
	 * Draws the map according to the active layer and scale.
	 */
	public bool on_draw (Cairo.Context ctx) {
		// Get the visible rect
		var visible_rect = this.get_visible_rect ();

		// If the visible rect is different from the already drawn rect
		if (visible_rect != this.drawn_rect) {
			// Update the surfaces and do selective cleaning and drawing
			this.update_surfaces (visible_rect);
			this.clean_surfaces (visible_rect);
			this.draw_surfaces (visible_rect);

			// Update the drawn tiles rect
			this.drawn_rect.set_values (
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
		switch (this.current_layer) {
			case LayerType.LOWER:
				// Paint the lower layer
				ctx.set_source_surface (this.surface_lower_layer, x, y);
				ctx.set_operator (Cairo.Operator.SOURCE);
				ctx.paint ();

				// Blend the upper layer with opacity 0.5
				ctx.set_operator (Cairo.Operator.OVER);
				ctx.set_source_surface (this.surface_upper_layer, x, y);
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

		draw_preview(ctx);

		return true;
	}

	/**
	 * Renders a preview of map changes based on the selected action and tiles
	 * in the tile palette.
	 */
	public bool draw_preview (Cairo.Context ctx) {
		MainWindow window = (MainWindow) this.get_toplevel ();
		DrawingTool action = (DrawingTool) window.get_current_drawing_tool ();
		Rect selected = this.palette.getSelectedArea (tile_size);

		switch (action) {
			case DrawingTool.PEN:
			case DrawingTool.RECTANGLE:
			case DrawingTool.CIRCLE:
			case DrawingTool.FILL:
				ctx.set_source_rgb (1.0,1.0,1.0);
				ctx.set_line_width (2.0);
				ctx.rectangle (cursor_x * tile_size, cursor_y * tile_size, selected.width, selected.height);
				ctx.stroke ();
				return true;
			default:
				return false;
		}
	}

	/**
	 * Manages the reactions to the pointer motion signal.
	 */
	public bool on_motion (Gdk.EventMotion event) {
		int x = ((int) event.x) / this.tile_size;
		int y = ((int) event.y) / this.tile_size;

		if(x != cursor_x || y != cursor_y) {
			cursor_x = x;
			cursor_y = y;

			this.queue_draw ();
		}

		return true;
	}
}
