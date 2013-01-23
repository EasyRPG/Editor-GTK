/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * Copyright (C) 2012-2013 EasyRPG Project
 *
 * License: https://github.com/EasyRPG/Editor/blob/master/COPYING GPL
 *
 * Authors:
 * - Aitor García (Falc) <aitor.falc@gmail.com>
 */

/**
 * A tiled DrawingArea that represents a map.
 */
public abstract class TiledMapDrawingArea : TiledDrawingArea {
	/*
	 * References
	 */
	protected weak Gtk.ScrolledWindow scrolled_window;
	public AbstractImageset? lower_layer_imageset {get; set; default = null;}
	public AbstractImageset? upper_layer_imageset {get; set; default = null;}

	/*
	 * Status values
	 */
	private LayerType current_layer;
	private DrawingTool current_drawing_tool;

	/*
	 * Schemes
	 */
	protected int[,] lower_layer_scheme;
	protected int[,] upper_layer_scheme;
	protected bool[,] draw_status;
	protected Rect drawn_tiles;

	/*
	 * Surfaces
	 */
	protected Cairo.ImageSurface lower_layer_surface;
	protected Cairo.ImageSurface upper_layer_surface;

	/**
	 * Builds the TiledMapDrawingArea.
	 */
	public TiledMapDrawingArea (Gtk.ScrolledWindow scrolled_window) {
		this.scrolled_window = scrolled_window;

		this.set_tile_width (16);
		this.set_tile_height (16);

		this.set_size_request (-1, -1);
		this.set_halign (Gtk.Align.CENTER);
		this.set_valign (Gtk.Align.CENTER);
	}

	/**
	 * Gets the current layer.
	 */
	public LayerType get_current_layer () {
		return this.current_layer;
	}

	/**
	 * Sets the current layer.
	 */
	public virtual void set_current_layer (LayerType layer) {
		this.current_layer = layer;
	}

	/**
	 * Gets the current drawing tool.
	 */
	public DrawingTool get_current_drawing_tool () {
		return this.current_drawing_tool;
	}

	/**
	 * Sets the current drawing tool.
	 */
	public virtual void set_current_drawing_tool (DrawingTool drawing_tool) {
		this.current_drawing_tool = drawing_tool;
	}
	
	/**
	 * Gets a copy of a layer scheme.
	 *
	 * This is a convenience method that simplifies the code required to get a
	 * layer scheme, since it accepts get_current_layer () as a parameter.
	 */
	public int[,]? get_layer_scheme (LayerType layer) {
		switch (layer) {
			case LayerType.LOWER:
				return this.lower_layer_scheme;

			case LayerType.UPPER:
				return this.upper_layer_scheme;

			default:
				return null;
		}
	}

	/**
	 * Sets a layer scheme.
	 *
	 * This is a convenience method that simplifies the code required to set a
	 * layer scheme, since it accepts get_current_layer () as a parameter.
	 */
	public void set_layer_scheme (LayerType layer, int[,] layer_scheme) {
		switch (layer) {
			case LayerType.LOWER:
				this.lower_layer_scheme = layer_scheme;
				break;

			case LayerType.UPPER:
				this.upper_layer_scheme = layer_scheme;
				break;

			default:
				break;
		}
	}

	/**
	 * Gets a reference to the specified layer surface.
	 *
	 * This is a convenience method that simplifies the code required to get a
	 * layer surface, since it accepts get_current_layer () as a parameter.
	 */
	public Cairo.ImageSurface? get_layer_surface (LayerType layer) {
		switch (layer) {
			case LayerType.LOWER:
				return this.lower_layer_surface;

			case LayerType.UPPER:
				return this.upper_layer_surface;

			default:
				return null;
		}
	}

	/**
	 * Loads the layer schemes.
	 */
	public void load_layer_schemes (int[,] lower_layer_scheme, int[,] upper_layer_scheme) {
		this.lower_layer_scheme = lower_layer_scheme;
		this.upper_layer_scheme = upper_layer_scheme;

		// Map width and height (in tiles)
		this.set_width_in_tiles (lower_layer_scheme.length[1]);
		this.set_height_in_tiles (lower_layer_scheme.length[0]);
	}

	/**
	 * Gets the visible rect.
	 *
	 * Uses the scrollbars position and page size to find which tiles
	 * should be drawn on the DrawingArea.
	 */
	public Rect get_visible_rect () {
		var visible_rect = Rect (0, 0, this.get_width_in_tiles (), this.get_height_in_tiles ());

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
			int first_x = (int) (h_value / this.get_scaled_tile_width ());
			int first_y = (int) (v_value / this.get_scaled_tile_height ());

			// Coordinates of the bottom-right tile to be drawn (last one)
			int last_x = (int) ((h_value + h_page_size) / this.get_scaled_tile_width ());
			int last_y = (int) ((v_value + v_page_size) / this.get_scaled_tile_height ());

			if (last_x > this.get_width_in_tiles () - 1) {
				last_x = this.get_width_in_tiles () - 1;
			}

			if (last_y > this.get_height_in_tiles () - 1) {
				last_y = this.get_height_in_tiles () - 1;
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
	protected void update_surfaces (Rect visible_rect) {
		// New references for the layer surfaces
		var old_lower_layer = this.lower_layer_surface;
		var old_upper_layer = this.upper_layer_surface;

		// Set a new size for the surfaces
		int surface_width = visible_rect.width * this.get_scaled_tile_width ();
		int surface_height = visible_rect.height * this.get_scaled_tile_height ();

		// Create new surfaces
		this.lower_layer_surface = new Cairo.ImageSurface (Cairo.Format.RGB24, surface_width, surface_height);
		this.upper_layer_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, surface_width, surface_height);

		// Find how many tiles should be shifted to the right and bottom
		int offset_x = (this.drawn_tiles.x - visible_rect.x) * this.get_scaled_tile_width ();
		int offset_y = (this.drawn_tiles.y - visible_rect.y) * this.get_scaled_tile_height ();

		// Draw the tiles
		var ctx = new Cairo.Context (this.lower_layer_surface);
		ctx.set_source_surface (old_lower_layer, offset_x, offset_y);
		ctx.paint ();

		ctx = new Cairo.Context (this.upper_layer_surface);
		ctx.set_source_surface (old_upper_layer, offset_x, offset_y);
		ctx.paint ();
	}

	/**
	 * Cleans the surfaces removing the tiles that are not displayed anymore
	 * in the DrawingArea, determined by the visible rect.
	 */
	protected void clean_surfaces (Rect visible) {
		var drawn = this.drawn_tiles;

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
	protected void clean_tiles_rect (Rect rect) {
		int col = rect.x;
		int row = rect.y;

		while (row < rect.y + rect.height) {
			bool is_drawn = this.draw_status[row, col];

			// If drawn, mark as not drawn
			if (is_drawn) {
				this.draw_status[row, col] = false;
			}

			col++;

			// Advance to the next row whecleaning is complete for this rowed
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
	protected void draw_surfaces (Rect visible) {
		var drawn = this.drawn_tiles;

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
	protected void draw_tiles_rect (Rect rect, int dest_x = 0, int dest_y = 0) {
		int col = 0;
		int row = 0;

		while (row < rect.height) {
			bool is_drawn = this.draw_status[rect.y + row, rect.x + col];

			// Draw the tile if not already drawn
			if (!is_drawn) {
				// Get the tile ids
				int lower_tile_id = this.lower_layer_scheme[rect.y + row, rect.x + col];
				int upper_tile_id = this.upper_layer_scheme[rect.y + row, rect.x + col];

				// Get and draw the lower layer tile, if any
				if (lower_tile_id != 0) {
					var surface_tile = this.lower_layer_imageset.get_image (lower_tile_id);
					// The standard 16x16 tile size is used because of the use of scale ()
					this.draw_tile (surface_tile, this.lower_layer_surface, (dest_x + col) * 16, (dest_y + row) * 16);
				}
				else {
					this.clear_tile (this.lower_layer_surface, (dest_x + col) * 16, (dest_y + row) * 16);
				}

				// Get and draw the upper layer tile, if any
				if (upper_tile_id != 0) {
					var surface_tile = this.upper_layer_imageset.get_image (upper_tile_id);
					// The standard 16x16 tile size is used because of the use of scale ()
					this.draw_tile (surface_tile, this.upper_layer_surface, (dest_x + col) * 16, (dest_y + row) * 16);
				}
				else {
					this.clear_tile (this.upper_layer_surface, (dest_x + col) * 16, (dest_y + row) * 16);
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
	 * Clears surfaces.
	 */
	protected void clear_surfaces () {
		this.lower_layer_surface = null;
		this.upper_layer_surface = null;
	}

	/**
	 * Clears schemes.
	 */
	protected void clear_schemes () {
		this.lower_layer_scheme = {{},{}};
		this.upper_layer_scheme = {{},{}};
		this.draw_status = {{},{}};
	}

	/**
	 * Clears the TiledMapDrawingArea.
	 */
	public void clear () {
		// Clear imagesets
		this.lower_layer_imageset.clear ();
		this.upper_layer_imageset.clear ();

		this.clear_surfaces ();
		this.clear_schemes ();
	}
}