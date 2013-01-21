/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * Copyright (C) 2012 EasyRPG Project
 *
 * License: https://github.com/EasyRPG/Editor/blob/master/COPYING GPL
 *
 * Authors:
 * - Aitor García (Falc) <aitor.falc@gmail.com>
 */

/**
 * Adds the tile painting feature.
 */
public interface IPaintTiles : TiledMapDrawingArea, ISelectTiles {
	// Tileset
	public abstract Tileset tileset {get; set; default = null;}

	// The painting layer and painted tiles
	public abstract Cairo.ImageSurface surface_painting_layer {get; set; default = null;}
	public abstract int[,] painted_tiles {get; set; default = null;}

	/**
	 * Paints with pencil.
	 */
	protected void paint_with_pencil (Rect selector) {
		// Normalize the selector rect
		selector.normalize ();

		// Create a new surface with the same size as the selector
		this.surface_painting_layer = new Cairo.ImageSurface (
			Cairo.Format.ARGB32,
			selector.width * this.get_tile_width (),
			selector.height * this.get_tile_height ()
		);

		// Copy the selected tiles to the drawing layer surface
		var ctx = new Cairo.Context (this.surface_painting_layer);
		ctx.rectangle (
			0, 0,
			this.surface_painting_layer.get_width (),
			this.surface_painting_layer.get_height ()
		);

		// Sets the correct scale factor
		switch (this.get_current_scale ()) {
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

		ctx.set_source_surface (
			this.tileset.get_layer_tiles (this.get_current_layer ()),
			-selector.x * 16,
			-selector.y * 16
		);

		ctx.get_source ().set_filter (Cairo.Filter.FAST);
		ctx.set_operator (Cairo.Operator.SOURCE);
		ctx.fill ();

		// Store the painted tiles ids
		this.painted_tiles = this.tileset.get_tiles_ids (selector);

		// Redraw the DrawingArea
		this.queue_draw ();
	}

	/**
	 * Copies the painted tiles to the scecified layer.
	 */
	protected void apply_painted_tiles (LayerType layer) {
		// Get the destination layer scheme and surface
		int[,] scheme = this.get_layer_scheme (layer);
		Cairo.ImageSurface surface_dest = this.get_layer_surface (layer);

		int col = 0;
		int row = 0;
		int tile_id = 0;

		while (row < this.tile_selector.height) {
			// Get the tile id
			tile_id = this.painted_tiles[row, col];

			// Update the tile id in the layer scheme
			scheme[this.tile_selector.y + row, this.tile_selector.x + col] = tile_id;

			col++;

			// Advance to the next row when the last col has been reached
			if (col == this.tile_selector.width) {
				col = 0;
				row++;
			}
		}

		// Set the new layer scheme
		this.set_layer_scheme (layer, scheme);

		// Copy the tile selector rect and normalize it
		Rect selector = this.tile_selector;
		selector.normalize ();

		// The visible_rect x,y coordinates are used as offsets
		Rect visible_rect = this.get_visible_rect ();
		int offset_x = visible_rect.x;
		int offset_y = visible_rect.y;

		var ctx = new Cairo.Context (surface_dest);
		ctx.rectangle (
			(selector.x - offset_x) * this.get_tile_width (),
			(selector.y - offset_y) * this.get_tile_height (),
			selector.width * this.get_tile_width (),
			selector.height * this.get_tile_height ()
		);
		
		ctx.set_source_surface (
			this.surface_painting_layer,
			(selector.x - offset_x) * this.get_tile_width (),
			(selector.y - offset_y) * this.get_tile_height ()
		);

		ctx.set_operator (Cairo.Operator.SOURCE);
		ctx.fill ();

		// Set the surface to null
		this.surface_painting_layer = null;

		// Redraw the DrawingArea
		this.queue_draw ();
	}

	protected void draw_painting_layer (Cairo.Context ctx, int x = 0, int y = 0) {
		// If the painting layer is not defined, stop the process
		if (this.surface_painting_layer == null) {
			return;
		}

		ctx.rectangle (
			x, y,
			this.surface_painting_layer.get_width (),
			this.surface_painting_layer.get_height ()
		);
			
		ctx.set_source_surface (this.surface_painting_layer, x, y);
		ctx.set_operator (Cairo.Operator.OVER);
		ctx.fill ();
	}
}
