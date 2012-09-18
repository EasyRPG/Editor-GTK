/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * tileset.vala
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

public class Tileset {
	private GLib.HashTable<int, Cairo.ImageSurface> autotiles;
	private Cairo.ImageSurface surface_lower_layer_tiles;
	private Cairo.ImageSurface surface_upper_layer_tiles;

	/**
	 * MapTileset constructor.
	 *
	 * The tileset file is split in two surfaces, one for the lower tiles and
	 * another one for the upper tiles. The autotiles are stored as independent
	 * surfaces in a hashtable.
	 */
	public Tileset (string tileset_file) {
		var surface_tileset = new Cairo.ImageSurface.from_png (tileset_file);

		// Lower layer palette has 6x27 tiles, the first 6x3 tiles contain autotiles
		this.surface_lower_layer_tiles = new Cairo.ImageSurface (Cairo.Format.ARGB32, 96, 432);

		// Upper layer palette has 6x24 tiles
		this.surface_upper_layer_tiles = new Cairo.ImageSurface (Cairo.Format.ARGB32, 96, 384);

		// Load process
		this.autotiles = new GLib.HashTable<int, Cairo.ImageSurface> (null, null);
		this.load_autotiles (surface_tileset);
		this.load_lower_tiles (surface_tileset);
		this.load_upper_tiles (surface_tileset);
	}

	/**
	 * Returns a reference to the lower surface.
	 */
	public Cairo.ImageSurface get_lower_layer_tiles () {
		return this.surface_lower_layer_tiles;
	}

	/**
	 * Returns a reference to the upper surface.
	 */
	public Cairo.ImageSurface get_upper_layer_tiles () {
		return this.surface_upper_layer_tiles;
	}

	/**
	 * Returns a reference to the specified surface.
	 */
	public Cairo.ImageSurface? get_layer_tiles (LayerType layer) {
		switch (layer) {
			case LayerType.LOWER:
				return this.get_lower_layer_tiles ();

			case LayerType.UPPER:
			case LayerType.EVENT:
				return this.get_upper_layer_tiles ();

			default:
				return null;
		}
	}

	/**
	 * Returns the rectangle of selected tiles prepared
	 * for Drawing to Surfaces.
	 */
	public Rect get_selected_area (Rect selected_tiles, int tile_size) {
		int x = selected_tiles.x * tile_size;
		int y = selected_tiles.y * tile_size;
		int w = selected_tiles.width * tile_size;
		int h = selected_tiles.height * tile_size;

		if (w < 0) {
			w = -w;
			x -= w;
		}

		if (h < 0) {
			h *= -1;
			y -= h;
		}

		w += tile_size;
		h += tile_size;

		return Rect (x, y, w, h);
	}

	/**
	 * Splits the autotiles in blocks that are stored in independent surfaces.
	 */
	private void load_autotiles (Cairo.ImageSurface surface_tileset) {
		Cairo.Context ctx;
		Cairo.ImageSurface surface_block;

		// Since water binds in a diferent way and merges with deep water,
		// we need a diferent way to bind it
		this.generate_binded_water(surface_tileset);
		
		// Each tileset contains 5 columns with a size of 6x16 tiles (96x256 pixels) 
		int tileset_col = 0;

		// Each tileset column contains 4 blocks with a size of 3x4 tiles (48x64 pixels)
		// Anyway we should skip water colums because they are already stored
		int block_col = 1;
		int block_row = 1;

		int tile_id = 4;
		
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

			/**
			 * Generate binded cache and store them on hash table
			 */
			this.generate_binded_tiles (tile_id, surface_block);

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
	 * Used for water binding code generation
	 * 1- WaterA
	 * 2- WaterB
	 * 3- DeepWater
	 * 4- Ground
	 **/
	private bool is_water(int tile_id){
		if (tile_id < 4)
			return true;
		return false;
	}

	/**
	 * Used for water binding code generation
	 **/
	private bool is_dwater(int tile_id){
		if (tile_id == 3)
			return true;
		return false;
	}

	/**
	 * Used for water binding code generation
	 **/
	private bool is_abwater(int tile_id){
		if (tile_id == 1 || tile_id == 2)
			return true;
		return false;
	}
	
	/**
	 * Generate al posible water combinations and store them on autotiles
	 */
	private void generate_binded_water(Cairo.ImageSurface surcace_tileset){

		/**
		 * Simulate all posible combinations
		 **/
		int[4] terrain_ids = {1,2,3,4};
		/**
		 * 1- WaterA
		 * 2- WaterB
		 * 3- DeepWater
		 * 4- Ground
		 **/
		
		// Main foreach controlates base water type
		foreach (int tile_id in terrain_ids)
		foreach (int tile_u in terrain_ids)
		foreach (int tile_d in terrain_ids)
		foreach (int tile_l in terrain_ids)
		foreach (int tile_r in terrain_ids)
		foreach (int tile_ul in terrain_ids)
		foreach (int tile_ur in terrain_ids)
		foreach (int tile_dl in terrain_ids)
		foreach (int tile_dr in terrain_ids){
			if (tile_id == 4)
				// Once main foreach reaches ground, we have finished
				break;
			// Initialize code vars
			int u=1, d=2, l=4, r=8, ul=0, ur=0, dl=0, dr=0;
			
			if (is_water (tile_u))
			    u = 0;
			if (is_water (tile_d))
			    d = 0;
			if (is_water (tile_l))
			    l = 0;
			if (is_water (tile_r))
			    r = 0;
			// DeepWater Special Corners
			//UpperLeft
			if (is_dwater (tile_id)){
				if (is_abwater(tile_u) && is_abwater (tile_l) && is_abwater (tile_ul))
					ul = 21;}
			else{
				if (is_dwater (tile_u) && is_dwater (tile_l))
					ul = 21;}
			//UpperRight
			if (is_dwater (tile_id)){
				if (is_abwater(tile_u) && is_abwater (tile_r) && is_abwater (tile_ur))
					ur = 41;}
			else{
				if (is_dwater (tile_u) && is_dwater (tile_r))
					ur = 41;}
			//LowerLeft
			if (is_dwater (tile_id)){
				if (is_abwater(tile_d) && is_abwater (tile_l) && is_abwater (tile_dl))
					dl = 70;}
			else{
				if (is_dwater (tile_d) && is_dwater (tile_l))
					dl = 70;}
			//LowerRight
			if (is_dwater (tile_id)){
				if (is_abwater(tile_d) && is_abwater (tile_r) && is_abwater (tile_dr))
					dr = 138;}
			else{
				if (is_dwater (tile_d) && is_dwater (tile_r))
					dr = 138;}
			//Overdraw ground corners
			if ((u+l) == 0 && tile_ul == 4)
			    ul = 16;
			if ((u+r) == 0 && tile_ur == 4)
			    ur = 32;
			if ((d+l) == 0 && tile_dl == 4)
			    dl = 64;
			if ((d+r) == 0 && tile_dr == 4)
			    dr = 128;

			int binding_code = tile_id * 300 + u+d+l+r+ul+ur+dl+dr;
			// Skip painting if tile is already stored
			if (this.autotiles.get(binding_code) != null)
				continue;

			// Water B uses second block of 3x4 tiles for borders
			// Water A and Deep Water uses first block
			int border_xoffset = (tile_id == 2) ? 48 : 0;

			/*
			 * Get base
			 */
			var surface_tile = new Cairo.ImageSurface (Cairo.Format.ARGB32, 16, 16);
			var ctx = new Cairo.Context (surface_tile);
			ctx.set_operator (Cairo.Operator.SOURCE);
			ctx.rectangle (0, 0, 16, 16);
			if (is_abwater (tile_id))
				ctx.set_source_surface (surcace_tileset, 0, -64);
			else
			    ctx.set_source_surface (surcace_tileset, 0, -112);
			ctx.fill ();

			// Draw Corners
			//UpperLeft corner
			int dest_x = 0, dest_y = 0;
			int corner = u+l+ul;
			if (corner > 0){
				ctx.rectangle (dest_x, dest_y, 8, 8);
				if (corner == 1)
					ctx.set_source_surface (surcace_tileset, dest_x-border_xoffset-0, dest_y-32);
				if (corner == 4)
					ctx.set_source_surface (surcace_tileset, dest_x-border_xoffset-0, dest_y-16);
				if (corner == 5)
					ctx.set_source_surface (surcace_tileset, dest_x-border_xoffset-0, dest_y-0);
				if (corner == 16)
					ctx.set_source_surface (surcace_tileset, dest_x-border_xoffset-0, dest_y-48);
				if (corner == 21){
					if (is_abwater (tile_id))
						ctx.set_source_surface (surcace_tileset, dest_x-0, dest_y-80);
					else
						ctx.set_source_surface (surcace_tileset, dest_x-0, dest_y-96);
				}
				ctx.fill();
			}

			//UpperRight corner
			dest_x = 8;
			dest_y = 0;
			corner = u+r+ur;
			if (corner > 0){
				ctx.rectangle (dest_x, dest_y, 8, 8);
				if (corner == 1)
					ctx.set_source_surface (surcace_tileset, dest_x-border_xoffset-8, dest_y-32);
				if (corner == 8)
					ctx.set_source_surface (surcace_tileset, dest_x-border_xoffset-8, dest_y-16);
				if (corner == 9)
					ctx.set_source_surface (surcace_tileset, dest_x-border_xoffset-8, dest_y-0);
				if (corner == 32)
					ctx.set_source_surface (surcace_tileset, dest_x-border_xoffset-8, dest_y-48);
				if (corner == 41){
					if (is_abwater (tile_id))
						ctx.set_source_surface (surcace_tileset, dest_x-8, dest_y-80);
					else
						ctx.set_source_surface (surcace_tileset, dest_x-8, dest_y-96);
				}
				ctx.fill();
			}
			// corner
			dest_x = 0;
			dest_y = 8;
			corner = d+l+dl;
			if (corner > 0){
				ctx.rectangle (dest_x, dest_y, 8, 8);
				if (corner == 2)
					ctx.set_source_surface (surcace_tileset, dest_x-border_xoffset-0, dest_y-40);
				if (corner == 4)
					ctx.set_source_surface (surcace_tileset, dest_x-border_xoffset-0, dest_y-24);
				if (corner == 6)
					ctx.set_source_surface (surcace_tileset, dest_x-border_xoffset-0, dest_y-8);
				if (corner == 64)
					ctx.set_source_surface (surcace_tileset, dest_x-border_xoffset-0, dest_y-56);
				if (corner == 70){
					if (is_abwater (tile_id))
						ctx.set_source_surface (surcace_tileset, dest_x-0, dest_y-88);
					else
						ctx.set_source_surface (surcace_tileset, dest_x-0, dest_y-104);
				}
				ctx.fill();
			}
			    
			// corner
			dest_x = 8;
			dest_y = 8;
			corner = d+r+dr;
			if (corner > 0){
				ctx.rectangle (dest_x, dest_y, 8, 8);
				if (corner == 2)
					ctx.set_source_surface (surcace_tileset, dest_x-border_xoffset-8, dest_y-40);
				if (corner == 8)
					ctx.set_source_surface (surcace_tileset, dest_x-border_xoffset-8, dest_y-24);
				if (corner == 10)
					ctx.set_source_surface (surcace_tileset, dest_x-border_xoffset-8, dest_y-8);
				if (corner == 128)
					ctx.set_source_surface (surcace_tileset, dest_x-border_xoffset-8, dest_y-56);
				if (corner == 138){
					if (is_abwater (tile_id))
						ctx.set_source_surface (surcace_tileset, dest_x-8, dest_y-88);
					else
						ctx.set_source_surface (surcace_tileset, dest_x-8, dest_y-104);
				}
				ctx.fill();
			}
			/*
			 * Register tile
			 */
			this.autotiles.set (binding_code, surface_tile);
		}
	}
	/**
	 * Generate al posible ground combinations and store them on autotiles
	 */
	private void generate_binded_tiles (int tile_id, Cairo.ImageSurface surface_block){
		
		/**
		 * Simulate all posible combinations
		 */

		bool[2] is_binded = {true,false};

		foreach (bool bu in is_binded)
		foreach (bool bd in is_binded)
		foreach (bool bl in is_binded)
		foreach (bool br in is_binded)
		foreach (bool bul in is_binded)
		foreach (bool bur in is_binded)
		foreach (bool bdl in is_binded)
		foreach (bool bdr in is_binded){
			
			int u = 0, d = 0, l = 0, r = 0;
			if (bu) u = 1;
			if (bd) d = 2;
			if (bl) l = 4;
			if (br) r = 8;
			int ul = 0, ur = 0, dl = 0, dr = 0;
			if (u + l == 0 && bul)
				ul = 16;
			if (u + r == 0 && bur)
				ur = 32;
			if (d + l == 0 && bdl)
				dl = 64;
			if (d + r == 0 && bdr)
				dr = 128;
			

			/*
			 * Get base
			 */
			var surface_tile = new Cairo.ImageSurface (Cairo.Format.ARGB32, 16, 16);
			var ctx = new Cairo.Context (surface_tile);
			ctx.set_operator (Cairo.Operator.SOURCE);
			ctx.rectangle (0, 0, 16, 16);
			ctx.set_source_surface (surface_block, -16, -32);
			ctx.fill ();

			/*
			 * Draw upper_left corner
			 */
			int dest_x = 0;
			int dest_y = 0;
			if ((u + l + ul) != 0){
				ctx.rectangle (dest_x, dest_y, 8, 8);
				if (u + l + ul == 1)
					ctx.set_source_surface (surface_block, dest_x-16, dest_y-16);
				if (u + l + ul == 4)
					ctx.set_source_surface (surface_block, dest_x-0, dest_y-32);
				if (u + l + ul == 5)
					ctx.set_source_surface (surface_block, dest_x-0, dest_y-16);
				if (u + l + ul == 16)
					ctx.set_source_surface (surface_block, dest_x-32, dest_y-0);
				ctx.fill();
			}

			/*
			 * Draw upper_right corner
			 */
			dest_x = 8;
			if (u + r + ur > 0){
				ctx.rectangle (8, 0, 8, 8);
				if (u + r + ur == 1)
					ctx.set_source_surface (surface_block, dest_x-24, dest_y-16);
				if (u + r + ur == 8)
					ctx.set_source_surface (surface_block, dest_x-40, dest_y-32);
				if (u + r + ur == 9)
					ctx.set_source_surface (surface_block, dest_x-40, dest_y-16);
				if (u + r + ur == 32)
					ctx.set_source_surface (surface_block, dest_x-40, dest_y-0);
				ctx.fill();
			}
			
			/*
			 * Draw down_left corner
			 */
			dest_x = 0;
			dest_y = 8;
			if (d + l + dl > 0){
				ctx.rectangle (0, 8, 8, 8);
				if (d + l + dl == 2)
					ctx.set_source_surface (surface_block, dest_x-16, dest_y-56);
				if (d + l + dl == 4)
					ctx.set_source_surface (surface_block, dest_x-0, dest_y-40);
				if (d + l + dl == 6)
					ctx.set_source_surface (surface_block, dest_x-0, dest_y-56);
				if (d + l + dl == 64)
					ctx.set_source_surface (surface_block, dest_x-32, dest_y-8);
				ctx.fill ();
			}

			/*
			 * Draw down_right corner
			 */
			dest_x = 8;
			if (d + r + dr > 0){
			ctx.rectangle (8, 8, 8, 8);
			if (d + r + dr == 2)
				ctx.set_source_surface (surface_block, dest_x-24, dest_y-56);
			if (d + r + dr == 8)
				ctx.set_source_surface (surface_block, dest_x-40, dest_y-40);
			if (d + r + dr == 10)
				ctx.set_source_surface (surface_block, dest_x-40, dest_y-56);
			if (d + r + dr == 128)
				ctx.set_source_surface (surface_block, dest_x-40, dest_y-8);
				ctx.fill ();
			}
			
			/*
			 * Register tile
			 */
			int binding_code = (tile_id + 2)*300+ul+u+ur+l+r+dl+d+dr;
			this.autotiles.set (binding_code, surface_tile);
		}
	}
		

	/**
	 * Builds the lower tiles surface (used when designing the lower layer).
	 */
	private void load_lower_tiles (Cairo.ImageSurface surface_tileset) {
		var ctx = new Cairo.Context (this.surface_lower_layer_tiles);
		ctx.set_operator (Cairo.Operator.SOURCE);

		Cairo.ImageSurface surface_autotile;

		int dest_x = 0;
		int dest_y = 0;
		int orig_x = 0;
		int orig_y = 0;


		// For each autotile block, copy its representative tile to the palette
		
		ctx.rectangle (0, 0, 16, 16);
		ctx.set_source_surface (surface_tileset, 0, 0);
		ctx.fill();
		ctx.rectangle (16, 0, 16, 16);
		ctx.set_source_surface (surface_tileset, 16-48, 0);
		ctx.fill();
		ctx.rectangle (32, 0, 16, 16);
		ctx.set_source_surface (surface_tileset, 32, -80);
		ctx.fill();
		// The fourth animated autotile block works in a different way
		ctx.rectangle (48, 0, 48, 16);
		ctx.set_source_surface (surface_tileset, 0, -64);
		ctx.fill();
		// The remaining autotiles
		for (int tile_id = 5; tile_id < 17; tile_id++) {
			surface_autotile = this.autotiles.get ((tile_id + 2) * 300+15);
			dest_x = ((tile_id+1) % 6) * 16;
			dest_y = ((tile_id+1) / 6) * 16;
			ctx.rectangle (dest_x, dest_y, 16, 16);
			ctx.set_source_surface (surface_autotile, dest_x, dest_y);
			ctx.fill ();
		}
		
		// First part of the lower tiles (third tileset column, 96x256)
		dest_x = 0;
		dest_y = 48;
		orig_x = 192;
		orig_y = 0;
		
		ctx.rectangle (dest_x, dest_y, 96, 256);
		ctx.set_source_surface (surface_tileset, -192, 48);
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
		var ctx = new Cairo.Context (this.surface_upper_layer_tiles);
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
	 * Clears the DrawingArea.
	 */
	public void clear () {
		// Clear the surfaces
		this.surface_lower_layer_tiles = null;
		this.surface_upper_layer_tiles = null;

		// Empty the hashtable
		this.autotiles.remove_all ();
	}
	
	/**
	 * Returns a 16x16 surface with the desired tile.
	 */
	public Cairo.ImageSurface get_tile (int tile_id, LayerType layer, int? binding_code = null) {
		var surface_tile = new Cairo.ImageSurface (Cairo.Format.ARGB32, 16, 16);

		// Is an autotile?
		if (binding_code != null)
			return this.autotiles.get(tile_id * 300 + binding_code);
		
		// Find the tile coordinates
		int orig_x = ((tile_id - 1) % 6) * 16;
		int orig_y = ((tile_id - 1) / 6) * 16;

		var ctx = new Cairo.Context (surface_tile);
		ctx.rectangle (0, 0, 16, 16);

		if (layer == LayerType.LOWER) {
			ctx.set_source_surface (this.surface_lower_layer_tiles, -orig_x, -orig_y);
		}
		else {
			ctx.set_source_surface (this.surface_upper_layer_tiles, -orig_x, -orig_y);
		}

		// Paint the tile in the 16x16 surface
		ctx.set_operator (Cairo.Operator.SOURCE);
		ctx.fill ();

		return surface_tile;
	}

	/*
	 * Returns the id of the tile placed in the coordinates (x, y).
	 */
	public int get_tile_id (int x, int y) {
		// (row * num_cols) + (col + 1)
		int tile_id = (y * 6) + (x + 1);

		return tile_id;
	}

	/**
	 * Returns a matrix containing the ids of the tiles defined by tiles_rect.
	 */
	public int[,] get_tiles_ids (Rect tiles_rect) {
		// Normalize the tiles rect
		tiles_rect.normalize ();

		var tile_ids = new int[tiles_rect.height, tiles_rect.width];

		int col = tiles_rect.x;
		int row = tiles_rect.y;
		int tile_id = 0;

		// For each tile, get and store its id
		while (row < tiles_rect.y + tiles_rect.height) {
			tile_id = this.get_tile_id (col, row);
			tile_ids[row - tiles_rect.y, col - tiles_rect.x] = tile_id;

			col++;

			// Advance to the next row when the last col has been reached
			if (col == tiles_rect.x + tiles_rect.width) {
				col = tiles_rect.x;
				row++;
			}
		}

		return tile_ids;
	}
}