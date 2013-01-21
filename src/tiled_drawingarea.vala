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
	/*
	 * References
	 */
	public Tileset tileset {get; set; default = null;}

	/*
	 * Status values
	 */
	private Scale current_scale;

	/*
	 * Size properties
	 */
	// The real tile size
	private int tile_width;
	private int tile_height;

	// The scaled tile size (this changes based on the current scale)
	private int scaled_tile_width;
	private int scaled_tile_height;

	// The size (in tiles) of the DrawingArea
	private int width_in_tiles;
	private int height_in_tiles;

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
	protected void set_tile_width (int width) {
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
	protected void set_tile_height (int height) {
		this.tile_height = height;
	}

	/**
	 * Returns the scaled tile width.
	 */
	public int get_scaled_tile_width () {
		return this.scaled_tile_width;
	}

	/**
	 * Sets the scaled tile width.
	 */
	protected void set_scaled_tile_width (int width) {
		this.scaled_tile_width = width;
	}

	/**
	 * Returns the scaled tile height.
	 */
	public int get_scaled_tile_height () {
		return this.scaled_tile_height;
	}

	/**
	 * Sets the scaled tile height.
	 */
	protected void set_scaled_tile_height (int height) {
		this.scaled_tile_height = height;
	}

	/**
	 * Returns the width in tiles.
	 */
	public int get_width_in_tiles () {
		return this.width_in_tiles;
	}

	/**
	 * Sets the width in tiles.
	 */
	protected void set_width_in_tiles (int width) {
		this.width_in_tiles = width;
	}

	/**
	 * Returns the height in tiles.
	 */
	public int get_height_in_tiles () {
		return this.height_in_tiles;
	}

	/**
	 * Sets the height in tiles.
	 */
	protected void set_height_in_tiles (int height) {
		this.height_in_tiles = height;
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
		ctx.rectangle (x, y, this.get_tile_width (), this.get_tile_height ());
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

		ctx.rectangle (x, y, this.get_tile_width (), this.get_tile_height ());
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
