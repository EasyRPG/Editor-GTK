/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * Copyright (C) 2013 EasyRPG Project
 *
 * License: https://github.com/EasyRPG/Editor/blob/master/COPYING GPL
 *
 * Authors:
 * - Aitor García (Falc) <aitor.falc@gmail.com>
 */

/**
 * A set that contains the map tiles.
 */
public abstract class RM2KChipsetImageset : AbstractImageset {
	/**
	 * Constructor.
	 */
	public RM2KChipsetImageset (string imageset_file) {
		// Call the parent constructor
		base (imageset_file);
	}

	/**
	 * Gets a surface containing the tile (16x16 pixels) specified by image_id.
	 */
	public override Cairo.ImageSurface get_image (int image_id) {
		var tile_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, 16, 16);

		// Find the tile coordinates
		int orig_x = ((image_id - 1) % 6) * 16;
		int orig_y = ((image_id - 1) / 6) * 16;

		var ctx = new Cairo.Context (tile_surface);
		ctx.rectangle (0, 0, 16, 16);
		ctx.set_source_surface (this.imageset_surface, -orig_x, -orig_y);

		// Paint the tile in the 16x16 surface
		ctx.set_operator (Cairo.Operator.SOURCE);
		ctx.fill ();

		return tile_surface;
	}

	/**
	 * Gets the id of the tile placed in the coordinates (x,y).
	 */
	public override int get_image_id (int x, int y) {
		// (row * num_cols) + (col + 1)
		return (y * 6) + (x + 1);
	}

	/**
	 * Gets a matrix containing the ids of the tiles defined by tiles_rect.
	 */
	public override int[,] get_image_ids (Rect tiles_rect) {
		// Normalize the tiles rect
		tiles_rect.normalize ();

		var tile_ids = new int[tiles_rect.height, tiles_rect.width];

		int col = tiles_rect.x;
		int row = tiles_rect.y;
		int tile_id = 0;

		// For each tile, get and store its id
		while (row < tiles_rect.y + tiles_rect.height) {
			tile_id = this.get_image_id (col, row);
			tile_ids[row - tiles_rect.y, col - tiles_rect.x] = tile_id;

			col++;

			// Advance to the next row when the last column has been reached
			if (col == tiles_rect.x + tiles_rect.width) {
				col = tiles_rect.x;
				row++;
			}
		}

		return tile_ids;
	}
}