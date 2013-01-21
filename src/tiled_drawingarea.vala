/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * Copyright (C) 2012 EasyRPG Project
 *
 * License: https://github.com/EasyRPG/Editor/blob/master/COPYING GPL
 *
 * Authors:
 * - Aitor García (Falc) <aitor.falc@gmail.com>
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
	private int tile_width;
	private int tile_height;
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
	 * Returns the tile width.
	 */
	public int get_tile_width () {
		return this.tile_width;
	}

	/**
	 * Sets the tile width.
	 */
	public void set_tile_width (int width) {
		this.tile_width = width;
	}

	/**
	 * Returns the tile height.
	 */
	public int get_tile_height () {
		return this.tile_height;
	}

	/**
	 * Sets the tile height.
	 */
	public void set_tile_height (int height) {
		this.tile_height = height;
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
