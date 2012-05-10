/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * tiled_map_drawingarea.vala
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
 * A tiled DrawingArea that represents a map.
 */
public abstract class TiledMapDrawingArea : TiledDrawingArea {
	// Status values
	private LayerType current_layer;
	private DrawingTool current_drawing_tool;

	// Map scheme
	protected int[,] lower_layer;
	protected int[,] upper_layer;
	protected bool[,] draw_status;

	// Layers
	protected Cairo.ImageSurface surface_lower_layer;
	protected Cairo.ImageSurface surface_upper_layer;
	protected Rect drawn_tiles;

	/**
	 * Returns the current layer.
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
	 * Returns a copy of a layer scheme.
	 *
	 * This is a convenience method that simplifies the code required to get a
	 * layer scheme, since it accepts get_current_layer () as a parameter.
	 */
	protected int[,]? get_layer_scheme (LayerType layer) {
		switch (layer) {
			case LayerType.LOWER:
				return this.lower_layer;

			case LayerType.UPPER:
				return this.upper_layer;

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
	protected void set_layer_scheme (LayerType layer, int[,] layer_scheme) {
		switch (layer) {
			case LayerType.LOWER:
				this.lower_layer = layer_scheme;
				break;

			case LayerType.UPPER:
				this.upper_layer = layer_scheme;
				break;

			default:
				break;
		}
	}

	/**
	 * Returns a reference to the specified layer surface.
	 *
	 * This is a convenience method that simplifies the code required to get a
	 * layer surface, since it accepts get_current_layer () as a parameter.
	 */
	protected Cairo.ImageSurface? get_layer_surface (LayerType layer) {
		switch (layer) {
			case LayerType.LOWER:
				return this.surface_lower_layer;

			case LayerType.UPPER:
				return this.surface_upper_layer;

			default:
				return null;
		}
	}

	/**
	 * Loads the layer schemes.
	 */
	public void load_layer_schemes (int[,] lower_layer, int[,] upper_layer) {
		this.lower_layer = lower_layer;
		this.upper_layer = upper_layer;

		// Map width and height (in tiles)
		this.width_in_tiles = lower_layer.length[1];
		this.height_in_tiles = lower_layer.length[0];
	}

	/**
	 * Clears the surfaces.
	 */
	protected void clear_surfaces () {
		this.surface_lower_layer = null;
		this.surface_upper_layer = null;
	}

	/**
	 * Clears the schemes.
	 */
	protected void clear_schemes () {
		this.lower_layer = {{},{}};
		this.upper_layer = {{},{}};
		this.draw_status = {{},{}};
	}

	/**
	 * Clears the DrawingArea.
	 */
	public override void clear () {
		base.clear ();

		this.clear_surfaces ();
		this.clear_schemes ();
	}
}