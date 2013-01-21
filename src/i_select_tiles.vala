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
 * Adds the tile selector feature.
 */
public interface ISelectTiles {
	// The tile selector rect
	public abstract Rect tile_selector {get; set; default = Rect (0, 0, 0, 0);}

	/**
	 * Clears the tile selector.
	 */
	protected void clear_selector () {
		this.tile_selector = Rect (0, 0, 0, 0);
	}

	/**
	 * Draws the tile selector in a Cairo Context.
	 */
	protected void draw_selector (Cairo.Context ctx, int tile_width, int tile_height) {
		// Create a copy of the rect and normalize it
		// The original tile_selector rect SHOULD NOT be normalized
		Rect selector = this.tile_selector;
		selector.normalize ();

		ctx.rectangle (
			selector.x * tile_width,
			selector.y * tile_height,
			selector.width * tile_width,
			selector.height * tile_height
		);

		// Selector properties
		ctx.set_source_rgb (1.0, 1.0, 1.0);
		ctx.set_line_width (2.0);
		ctx.set_operator (Cairo.Operator.OVER);

		ctx.stroke ();
	}
}
