/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * tiled_drawingarea.vala
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
 * A tiled DrawingArea.
 */
public abstract class TiledDrawingArea : Gtk.DrawingArea {
	// References
	public Tileset tileset {get; set; default = null;}

	// Status values
	private Scale current_scale;

	// Size properties
	public int tile_size;
	protected int width_in_tiles;
	protected int height_in_tiles;

	/**
	 * Returns the current scale.
	 */
	public Scale get_current_scale () {
		return this.current_scale;
	}

	/**
	 * Sets the current scale.
	 */
	public virtual void set_current_scale (Scale scale) {
		this.current_scale = scale;
	}

	/**
	 * Draws a tile on a surface.
	 */
	protected virtual void draw_tile (Cairo.ImageSurface tile, Cairo.ImageSurface surface, int x, int y) {
		var ctx = new Cairo.Context (surface);

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

		// Draws the tile on (x,y)
		ctx.rectangle (x, y, 16, 16);
		ctx.set_source_surface (tile, x, y);
		ctx.get_source ().set_filter (Cairo.Filter.FAST);
		ctx.set_operator (Cairo.Operator.SOURCE);

		ctx.fill ();
	}

	/**
	 * Clears a tile on a surface.
	 */
	protected virtual void clear_tile (Cairo.ImageSurface surface, int x, int y) {
		var ctx = new Cairo.Context (surface);

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

		ctx.rectangle (x, y, 16, 16);
		ctx.get_source ().set_filter (Cairo.Filter.FAST);
		ctx.set_operator (Cairo.Operator.CLEAR);

		ctx.fill ();
	}

	/**
	 * Connects the draw signal and redraws the DrawingArea.
	 */
	public void enable_draw () {
		this.draw.connect (this.on_draw);
	}

	/**
	 * Disconnects the draw signal.
	 */
	public void disable_draw () {
		this.draw.disconnect (this.on_draw);
	}

	/**
	 * Clears the tileset.
	 */
	protected void clear_tileset () {
		if (this.tileset != null) {
			this.tileset.clear ();
			this.tileset = null;
		}
	}

	/**
	 * Clears the DrawingArea.
	 */
	public virtual void clear () {
		this.clear_tileset ();
	}

	/**
	 * Manages the reactions to the draw signal.
	 */
	protected abstract bool on_draw (Cairo.Context ctx);
}