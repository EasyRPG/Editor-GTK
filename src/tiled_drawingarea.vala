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
	protected Tileset tileset;

	// Status values
	private Scale current_scale;

	// Size properties
	protected int tile_size;
	protected int width_in_tiles;
	protected int height_in_tiles;

	/**
	 * Sets a tileset.
	 */
	public void set_tileset (Tileset tileset) {
		this.tileset = tileset;
	}

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