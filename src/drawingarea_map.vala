/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * drawingarea_map.vala
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
 * The map DrawingArea.
 */
public class MapDrawingArea : Gtk.DrawingArea {
	private TilePaletteDrawingArea palette;
	private int[,] lower_layer;
	private Cairo.ImageSurface surface_lower_layer;
	private int[,] upper_layer;
	private Cairo.ImageSurface surface_upper_layer;
	private LayerType current_layer;
	private Scale current_scale;

	/**
	 * Builds the map DrawingArea.
	 */
	public MapDrawingArea (TilePaletteDrawingArea palette) {
		this.palette = palette;
		this.set_size_request (-1, -1);
		this.set_halign (Gtk.Align.CENTER);
		this.set_valign (Gtk.Align.CENTER);
	}

	/**
	 * Loads the map.
	 * 
	 * Gets the layer schemes and reads them to draw the tiles in each layer surface.
	 */
	public void load_map (int[,] lower_layer, int[,] upper_layer) {
		this.lower_layer = lower_layer;
		this.upper_layer = upper_layer;

		// Map width and height (in tiles) 
		int width = this.lower_layer.length[1];
		int height = this.lower_layer.length[0];

		// Cairo surface instances
		this.surface_lower_layer = new Cairo.ImageSurface (Cairo.Format.RGB24, width * 16, height * 16);
		this.surface_upper_layer = new Cairo.ImageSurface (Cairo.Format.ARGB32, width * 16, height * 16);

		// Layer schemes traversing
		for (int i = 0; i < width * height; i++) {
			// Find the tile coordinates
			int col = i % width;
			int row = i / width;

			// Get the tile ids for this position
			int lower_tile_id = this.lower_layer[row,col];
			int upper_tile_id = this.upper_layer[row,col];

			// Get and draw the lower layer tile if any
			if (lower_tile_id != 0) {
				var surface_tile = this.palette.get_tile (lower_tile_id, LayerType.LOWER);
				this.draw_tile (surface_tile, this.surface_lower_layer, col * 16, row * 16);
			}

			// Get and draw the upper layer tile if any
			if (upper_tile_id != 0) {
				var surface_tile = this.palette.get_tile (upper_tile_id, LayerType.UPPER);
				this.draw_tile (surface_tile, this.surface_upper_layer, col * 16, row * 16);
			}
		}

		// Redraw the DrawingArea and start reacting to the draw signal
		this.draw.connect (on_draw);
		this.queue_draw ();
	}

	/**
	 * Draws a tile in the given surface and position.
	 */
	private void draw_tile (Cairo.ImageSurface tile, Cairo.ImageSurface surface, int dest_x, int dest_y) {
		var ctx = new Cairo.Context (surface);
		ctx.rectangle (dest_x, dest_y, 16, 16);
		ctx.set_source_surface (tile, dest_x, dest_y);
		ctx.fill ();
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
	 * Update the DrawingArea sized based in the selected scale.
	 */
	public void set_scale (Scale scale) {
		this.current_scale = scale;

		switch (scale) {
			case Scale.1_1:
				this.set_size_request (
					this.lower_layer.length[1] * 32,
				    this.lower_layer.length[0] * 32
				);
				break;
			case Scale.1_2:
				this.set_size_request (
					this.lower_layer.length[1] * 16,
				    this.lower_layer.length[0] * 16
				);
				break;
			case Scale.1_4:
				this.set_size_request (
					this.lower_layer.length[1] * 8,
				    this.lower_layer.length[0] * 8
				);
				break;
			case Scale.1_8:
				this.set_size_request (
					this.lower_layer.length[1] * 4,
				    this.lower_layer.length[0] * 4
				);
				break;
			default:
				return;
		}

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

		// Change the size to fluid
		this.set_size_request (-1, -1);

		// Redraw the DrawingArea and don't react anymore to the draw signal
		this.queue_draw ();
		this.draw.disconnect (on_draw);
	}

	/**
	 * Manages the reactions to the draw signal.
	 * 
	 * Draw the map according to the active layer and scale.
	 */
	public bool on_draw (Cairo.Context ctx) {
		// Map width and height (in tiles)
		int width = this.lower_layer.length[1];
		int height = this.lower_layer.length[0];

		// Surface width and height
		int surface_width = this.surface_lower_layer.get_width ();
		int surface_height = this.surface_lower_layer.get_height ();

		// Default tile size
		int tile_size = 16;

		// Set the draw scale and adapt the surface and tile sizes to it 
		switch (this.current_scale) {
			// Scale 2x (32x32 tile size)
			case Scale.1_1:
				ctx.scale (2, 2);
				surface_width *= 2;
				surface_height *= 2;
				tile_size = 32;
				break;
			// Scale 1x (16x16 tile size)
			case Scale.1_2:
				ctx.scale (1, 1);
				break;
			// Scale 0.5x (8x8 tile size)
			case Scale.1_4:
				ctx.scale (0.5, 0.5);
				surface_width /= 2;
				surface_height /= 2;
				tile_size = 8;
				break;
			// Scale 0.25x (4x4 tile size)
			case Scale.1_8:
				ctx.scale (0.25, 0.25);
				surface_width /= 4;
				surface_height /= 4;
				tile_size = 4;
				break;
			default:
				return false;
		}

		// Set the draw order based in the active layer
		switch (this.current_layer) {
			case LayerType.LOWER:
				// Paint the lower layer
				ctx.set_source_surface (this.surface_lower_layer, 0, 0);
				ctx.get_source ().set_filter (Cairo.Filter.FAST);
				ctx.set_operator (Cairo.Operator.SOURCE);
				ctx.paint ();

				// Blend the upper layer with opacity 0.7
				ctx.set_source_surface (this.surface_upper_layer, 0, 0);
				ctx.get_source ().set_filter (Cairo.Filter.FAST);
				ctx.set_operator (Cairo.Operator.OVER);
				ctx.paint_with_alpha (0.7);
				break;
			case LayerType.UPPER:
				// Paint a black background
				ctx.set_source_rgb (0, 0, 0);
				ctx.set_operator (Cairo.Operator.SOURCE);
				ctx.paint ();

				/*
				 * TODO: This OVER paint with alpha 0.7 should be replaced in
				 * the future when all the operators are available (Vala 0.14.1?)
				 */
				// Blend the lower layer with opacity 0.7
				ctx.set_source_surface (this.surface_lower_layer, 0, 0);
				ctx.get_source ().set_filter (Cairo.Filter.FAST);
				ctx.set_operator (Cairo.Operator.OVER);
				ctx.paint_with_alpha (0.7);

				// Blend the upper layer
				ctx.set_source_surface (this.surface_upper_layer, 0, 0);
				ctx.get_source ().set_filter (Cairo.Filter.FAST);
				ctx.paint ();
				break;
			case LayerType.EVENT:
				// Paint the lower layer
				ctx.set_source_surface (this.surface_lower_layer, 0, 0);
				ctx.get_source ().set_filter (Cairo.Filter.FAST);
				ctx.set_operator (Cairo.Operator.SOURCE);
				ctx.paint ();

				// Blend the upper layer
				ctx.set_source_surface (this.surface_upper_layer, 0, 0);
				ctx.get_source ().set_filter (Cairo.Filter.FAST);
				ctx.set_operator (Cairo.Operator.OVER);
				ctx.paint ();

				// Restore the context to the initial state (default scale)
				ctx.restore ();
				ctx.set_source_rgb (0, 0, 0);

				/*
				 * Mask the grid vertical lines.
				 * The 0.5 pixel correction prevents blurry lines.
				 */
				for (double x = tile_size - 0.5; x < surface_width; x += tile_size) {
					ctx.move_to (x, 0);
					ctx.line_to (x, surface_height);
				}

				/*
				 * Mask the grid horizontal lines.
				 * The 0.5 pixel correction prevents blurry lines.
				 */
				for (double y = tile_size - 0.5; y < surface_height; y += tile_size) {
					ctx.move_to (0, y);
					ctx.line_to (surface_width, y);
				}

				// Draw the masked grid (one pixel wide lines) 
				ctx.set_line_width (1);
				ctx.stroke ();
				break;
			default:
				return false;
		}

		return true;
	}
}