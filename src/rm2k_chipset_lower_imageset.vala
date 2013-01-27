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
 * A set that contains the map autotiles and lower tiles.
 */
public class RM2KChipsetLowerImageset : RM2KChipsetImageset {
	// Autotiling blocks are stored as independent surfaces in a hash table
	private GLib.HashTable<int, Cairo.ImageSurface> autotiles_surfaces;

	/**
	 * Constructor.
	 */
	public RM2KChipsetLowerImageset (string imageset_file) {
		// Call the parent constructor
		base (imageset_file);

		// Lower layer palette has 6x27 tiles, the first 6x3 tiles contain autotiles
		this.imageset_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, 96, 432);
	}

	/**
	 * Retrieves all the tiles from the file and loads them into the surface.
	 */
	public override void load_images () {
		var chipset_surface = new Cairo.ImageSurface.from_png (imageset_file);

		this.autotiles_surfaces = new GLib.HashTable<int, Cairo.ImageSurface> (null, null);
		this.load_autotiles (chipset_surface);
		this.load_lower_tiles (chipset_surface);
	}

	/**
	 * Splits the autotiles in blocks and stores them.
	 */
	private void load_autotiles (Cairo.ImageSurface chipset_surface) {
		Cairo.Context ctx;
		Cairo.ImageSurface block_surface;

		// Each chipset contains 5 columns of 6x16 tiles (96x256 pixels)
		int chipset_col = 1;

		// Each chipset column contains 2x4 blocks of 3x4 tiles (48x64 pixels)
		int block_col = 1;
		int block_row = 1;

		int tile_id = 1;

		// The autotiles are stored in the first and second columns
		while (chipset_col < 3) {
			block_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, 48, 64);
			ctx = new Cairo.Context (block_surface);
			ctx.set_operator (Cairo.Operator.SOURCE);

			int dest_x = 0;
			int dest_y = 0;
			int orig_x = (2 * (chipset_col - 1) + (block_col - 1)) * 48;
			int orig_y = (block_row - 1) * 64;

			// Select the destination area, pos (0,0) size (48x64)
			ctx.rectangle (0, 0, 48, 64);

			// Adapt the block coordinates to the destination area and fill it
			ctx.set_source_surface (chipset_surface, dest_x - orig_x, dest_y - orig_y);
			ctx.fill ();

			// Store the surface in the autotiles hashtable
			this.autotiles_surfaces.set (tile_id, block_surface);

			tile_id++;
			block_col++;

			// This controls the block flow
			if (block_col > 2) {
				block_col = 1;
				block_row++;
			}

			// This controls the column flow
			if (block_row > 4) {
				block_row = 1;
				chipset_col++;
			}
		}
	}

	/**
	 * Builds the lower tiles surface (the surface used when designing the lower layer).
	 */
	private void load_lower_tiles (Cairo.ImageSurface chipset_surface) {
		var ctx = new Cairo.Context (this.imageset_surface);
		ctx.set_operator (Cairo.Operator.SOURCE);

		Cairo.ImageSurface autotile_surface;

		int dest_x = 0;
		int dest_y = 0;
		int orig_x = 0;
		int orig_y = 0;

		// For each autotiling block, copy its representative tile to the imageset surface (palette)
		for (int tile_id = 1; tile_id < 17; tile_id++) {
			autotile_surface = this.autotiles_surfaces.get (tile_id);

			// First three animated autotile blocks
			if (tile_id < 4) {
				dest_x = (tile_id - 1) * 16;
				ctx.rectangle (dest_x, dest_y, 16, 16);
				ctx.set_source_surface (autotile_surface, dest_x, dest_y);
			}
			// The fourth animated autotile block works in a different way
			else if (tile_id == 4) {
				dest_x = (tile_id - 1) * 16;
				ctx.rectangle (dest_x, dest_y, 48, 16);
				ctx.set_source_surface (autotile_surface, dest_x, dest_y);
			}
			// The remaining autotiles
			else {
				dest_x = ((tile_id + 1) % 6) * 16;
				dest_y = ((tile_id + 1) / 6) * 16;
				ctx.rectangle (dest_x, dest_y, 16, 16);
			}

			ctx.set_source_surface (autotile_surface, dest_x, dest_y);
			ctx.fill ();
		}

		// First part of the lower tiles (third tileset column, 96x256)
		dest_x = 0;
		dest_y = 48;
		orig_x = 192;
		orig_y = 0;

		ctx.rectangle (dest_x, dest_y, 96, 256);
		ctx.set_source_surface (chipset_surface, dest_x - orig_x, dest_y - orig_y);
		ctx.fill ();

		// Second part of the lower tiles (fourth tileset column, 96x128)
		dest_y = 304; // 48 + 256
		orig_x = 288;

		ctx.rectangle (dest_x, dest_y, 96, 128);
		ctx.set_source_surface (chipset_surface, dest_x - orig_x, dest_y - orig_y);
		ctx.fill ();		
	}
}