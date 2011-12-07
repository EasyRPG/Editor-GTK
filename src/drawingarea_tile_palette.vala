/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * drawingarea_tile_palette.vala
 * Copyright (C) EasyRPG Project 2011
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
	private Cairo.ImageSurface surface_lower_tiles;
	private Cairo.ImageSurface surface_upper_tiles;
	private GLib.HashTable<int, Cairo.ImageSurface> autotiles;
	private LayerType current_layer;

	/**
	 * Builds the tile palette DrawingArea.
	 */
	public TilePaletteDrawingArea () {
		this.set_size_request (192, -1);
		this.autotiles = new GLib.HashTable<int, Cairo.ImageSurface> (null, null);
	}

	/**
	 * Loads the tileset.
	 * 
	 * The tileset is split in two surfaces, one for the lower tiles and another
	 * for the upper tiles. The autotiles are stored as independent surfaces in
	 * a hashtable.
	 */
	public void load_tileset (string tileset) {
		var surface_tileset = new Cairo.ImageSurface.from_png (tileset);

		// Lower layer palette has 6x27 tiles, the first 6x3 tiles contain autotiles
		this.surface_lower_tiles = new Cairo.ImageSurface (Cairo.Format.ARGB32, 96, 432);

		// Upper layer palette has 6x24 tiles
		this.surface_upper_tiles = new Cairo.ImageSurface (Cairo.Format.ARGB32, 96, 384);

		// Load process
		this.load_autotiles (surface_tileset);
		this.load_lower_tiles (surface_tileset);
		this.load_upper_tiles (surface_tileset);

		this.draw.connect (on_draw);
	}

	/**
	 * Splits the autotiles in blocks that are stored in independent surfaces.
	 */
	private void load_autotiles (Cairo.ImageSurface surface_tileset) {
		Cairo.Context ctx;
		Cairo.ImageSurface surface_block;

		// Each tileset contains 5 columns with a size of 6x16 tiles (96x256 pixels) 
		int tileset_col = 0;

		// Each tileset column contains 4 blocks with a size of 3x4 tiles (48x64 pixels)
		int block_col = 0;
		int block_row = 0;

		int tile_id = 1;
		
		while (tileset_col < 2) {
			surface_block = new Cairo.ImageSurface (Cairo.Format.ARGB32, 48, 64);
			ctx = new Cairo.Context (surface_block);
			ctx.set_operator (Cairo.Operator.SOURCE);

			int dest_x = 0;
			int dest_y = 0;
			int orig_x = (2 * tileset_col + block_col) * 48;
			int orig_y = block_row * 64;

			// Select the destination area, pos (0,0) size (48,64)
			ctx.rectangle (0, 0, 48, 64);

			// Adapt the block coordinates to the destination area and fill it
			ctx.set_source_surface (surface_tileset, dest_x - orig_x, dest_y - orig_y);
			ctx.fill ();

			// Store the surface in the autotiles hashtable
			this.autotiles.set (tile_id, surface_block);

			tile_id++;
			block_col++;

			// Go to the next block
			if (block_col > 1) {
				block_col = 0;
				block_row++;
			}

			// Go to the next column
			if (block_row > 3) {
				block_row = 0;
				tileset_col++;
			}
		}
	}

	/**
	 * Builds the lower tiles surface (used when designing the lower layer).
	 */
	private void load_lower_tiles (Cairo.ImageSurface surface_tileset) {
		var ctx = new Cairo.Context (this.surface_lower_tiles);
		ctx.set_operator (Cairo.Operator.SOURCE);

		Cairo.ImageSurface surface_autotile;

		int dest_x = 0;
		int dest_y = 0;
		int orig_x = 0;
		int orig_y = 0;

		// For each autotile block, copy its representative tile to the palette
		for (int tile_id = 1; tile_id < 17; tile_id++) {
			surface_autotile = this.autotiles.get (tile_id);

			// First three animated autotile blocks
			if (tile_id < 4) {
				dest_x = (tile_id - 1) * 16;
				ctx.rectangle (dest_x, dest_y, 16, 16);
				ctx.set_source_surface (surface_autotile, dest_x, dest_y);
			}
			// The fourth animated autotile block works in a different way
			else if (tile_id == 4) {
				dest_x = (tile_id - 1) * 16;
				ctx.rectangle (dest_x, dest_y, 48, 16);
				ctx.set_source_surface (surface_autotile, dest_x, dest_y);
			}
			// The remaining autotiles
			else {
				dest_x = ((tile_id + 1) % 6) * 16;
				dest_y = ((tile_id + 1) / 6) * 16;
				ctx.rectangle (dest_x, dest_y, 16, 16);
			}

			ctx.set_source_surface (surface_autotile, dest_x, dest_y);
			ctx.fill ();
		}

		// First part of the lower tiles (third tileset column, 96x256)
		dest_x = 0;
		dest_y = 48;
		orig_x = 192;
		orig_y = 0;

		ctx.rectangle (dest_x, dest_y, 96, 256);
		ctx.set_source_surface (surface_tileset, dest_x - orig_x, dest_y - orig_y);
		ctx.fill ();

		// Second part of the lower tiles (fourth tileset column, 96x128)
		dest_y = 304; // 48 + 256
		orig_x = 288;

		ctx.rectangle (dest_x, dest_y, 96, 128);
		ctx.set_source_surface (surface_tileset, dest_x - orig_x, dest_y - orig_y);
		ctx.fill ();		
	}

	/**
	 * Builds the upper tiles surface (used when designing the upper layer).
	 */
	private void load_upper_tiles (Cairo.ImageSurface surface_tileset) {
		var ctx = new Cairo.Context (this.surface_upper_tiles);
		ctx.set_operator (Cairo.Operator.SOURCE);

		// First part of the upper tiles (fourth tileset column, 96x128)
		int dest_x = 0;
		int dest_y = 0;
		int orig_x = 288;
		int orig_y = 128;

		ctx.rectangle (dest_x, dest_y, 96, 128);
		ctx.set_source_surface (surface_tileset, dest_x - orig_x, dest_y - orig_y);
		ctx.fill ();

		// Second part of the upper tiles (fifth tileset column, 96x256)
		dest_y = 128;
		orig_x = 384;
		orig_y = 0;

		ctx.rectangle (dest_x, dest_y, 96, 256);
		ctx.set_source_surface (surface_tileset, dest_x - orig_x, dest_y - orig_y);
		ctx.fill ();
	}

	/**
	 * Manages the reactions to the layer change.
	 * 
	 * Display the correct palette for the selected layer.
	 */
	public void set_layer (LayerType layer) {
		this.current_layer = layer;

		switch (layer) {
			case LayerType.LOWER:
				this.set_size_request (
					this.surface_lower_tiles.get_width () * 2,
					this.surface_lower_tiles.get_height () * 2
				);
				break;
			case LayerType.UPPER:
			case LayerType.EVENT:
				this.set_size_request (
					this.surface_upper_tiles.get_width () * 2,
					this.surface_upper_tiles.get_height () * 2
				);
				break;
			default:
				return;
		}

		// Redraw the DrawingArea
		this.queue_draw ();
	}

	/**
	 * Returns a 16x16 surface with the desired tile.
	 */
	public Cairo.ImageSurface get_tile (int tile_id, LayerType layer) {
		var surface_tile = new Cairo.ImageSurface (Cairo.Format.ARGB32, 16, 16);
		var ctx = new Cairo.Context (surface_tile);
		ctx.rectangle (0, 0, 16, 16);

		// Find the tile coordinates
		int orig_x = ((tile_id - 1) % 6) * 16;
		int orig_y = ((tile_id - 1) / 6) * 16;

		// Set the correct source
		if (layer == LayerType.LOWER) {
			ctx.set_source_surface (this.surface_lower_tiles, -orig_x, -orig_y);
		}
		else {
			ctx.set_source_surface (this.surface_upper_tiles, -orig_x, -orig_y);
		}

		// Paint the tile in the 16x16 surface
		ctx.fill ();

		return surface_tile;
	}

	/**
	 * Clears the DrawingArea.
	 */
	public void clear () {
		// Clear the surfaces
		this.surface_lower_tiles = null;
		this.surface_upper_tiles = null;

		// Empty the hashtable
		this.autotiles.remove_all ();

		// Make sure it keeps the correct size
		this.set_size_request (192, -1);

		// Redraw the DrawingArea and don't react anymore to the draw signal	
		this.queue_draw ();
		this.draw.disconnect (on_draw);
	}

	/**
	 * Manages the reactions to the draw signal.
	 * 
	 * Draw the palette according to the active layer.
	 */
	public bool on_draw (Cairo.Context ctx) {
		// The palette must be scaled to 2x (32x32 tile size) 
		ctx.scale (2, 2);

		switch (this.current_layer) {
			case LayerType.LOWER:
				ctx.set_source_surface (this.surface_lower_tiles, 0, 0);
				break;
			case LayerType.UPPER:
			case LayerType.EVENT:
				ctx.set_source_surface (this.surface_upper_tiles, 0, 0);
				break;
			default:
				return false;
		}

		// Fast interpolation, similar to nearest-neighbor
		ctx.get_source ().set_filter (Cairo.Filter.FAST);
		ctx.paint ();

		return true;
	}
}