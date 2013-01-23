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
 * A set that contains the map upper tiles.
 */
public class RM2KChipsetUpperImageset : RM2KChipsetImageset {
	/**
	 * Constructor.
	 */
	public RM2KChipsetUpperImageset (string imageset_file) {
		// Call the parent constructor
		base (imageset_file);

		// Upper layer palette has 6x24 tiles
		this.imageset_surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, 96, 384);
	}

	/**
	 * Retrieves all the tiles from the file and loads them into the surface.
	 */
	public override void load_images () {
		var chipset_surface = new Cairo.ImageSurface.from_png (imageset_file);

		var ctx = new Cairo.Context (this.imageset_surface);
		ctx.set_operator (Cairo.Operator.SOURCE);

		// First part of the upper tiles (fourth tileset column, 96x128)
		int dest_x = 0;
		int dest_y = 0;
		int orig_x = 288;
		int orig_y = 128;

		ctx.rectangle (dest_x, dest_y, 96, 128);
		ctx.set_source_surface (chipset_surface, dest_x - orig_x, dest_y - orig_y);
		ctx.fill ();

		// Second part of the upper tiles (fifth tileset column, 96x256)
		dest_y = 128;
		orig_x = 384;
		orig_y = 0;

		ctx.rectangle (dest_x, dest_y, 96, 256);
		ctx.set_source_surface (chipset_surface, dest_x - orig_x, dest_y - orig_y);
		ctx.fill ();
	}
}