/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * i_select_tiles.vala
 * Copyright (C) EasyRPG Project 2012
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
 * Adds the tile selector feature.
 */
public interface ISelectTiles {
	// The tile selector rect
	public abstract Rect tile_selector {get; set; default = Rect (0, 0, 0, 0);}

	/**
	 * Draws the selector in a Cairo Context.
	 */
	protected void draw_selector (Cairo.Context ctx, int tile_size) {
		// Selector properties
		ctx.set_source_rgb (1.0,1.0,1.0);
		ctx.set_line_width (1.0);

		// Create a copy of the rect and normalize it
		// The original tile_selector rect SHOULD NOT be normalized
		Rect selector = this.tile_selector;
		selector.normalize ();

		ctx.rectangle (
			(double) selector.x * tile_size,
			(double) selector.y * tile_size,
			(double) selector.width * tile_size,
			(double) selector.height * tile_size
		);

		ctx.stroke ();
	}
}