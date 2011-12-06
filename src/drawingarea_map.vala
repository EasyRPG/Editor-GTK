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
	private Cairo.ImageSurface surface_lower_layer;
	private int[,] lower_layer;
	private Cairo.ImageSurface surface_upper_layer;
	private int[,] upper_layer;
	private Cairo.ImageSurface? surface_tileset;
	private LayerType current_layer;
	private int current_scale;

	public MapDrawingArea () {
		this.set_size_request (-1, -1);
	}

	/**
	 * Loads the data required by the Map DrawingArea in order to draw a map.
	 */
	public void load (string tileset, int[,] lower_layer, int[,] upper_layer) {

		if (tileset == "") {
			var surface_tileset_base = new Cairo.ImageSurface.from_png ("graphics/tilesets/" + tileset);

			
			this.surface_tileset = new Cairo.ImageSurface.from_png ("graphics/tilesets/" + tileset);
		}
		else {
			this.surface_tileset = null;
		}

		this.lower_layer = lower_layer;
		this.upper_layer = upper_layer;

// Construye la surface_lower_layer dibujando en Cairo
// Construye la surface_upper_layer dibujando en Cairo

		this.draw.connect (on_draw);
	}

	public void set_layer (LayerType layer) {
		this.current_layer = layer;
	}

	public void set_scale (int scale) {
		this.current_scale = scale;
	}

	public void clear () {
//		this.surface_map = null;
//		this.surface_tileset = null;
		this.draw.disconnect (on_draw);
	}

	public bool on_draw (Cairo.Context ctx) {
//		ctx.set_source_surface (this.surface_map, 0, 0);
//		ctx.paint ();
		return true;
	}
}