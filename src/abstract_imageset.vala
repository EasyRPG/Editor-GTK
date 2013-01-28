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
 * An abstract imageset.
 *
 * This will load and store a set of images that can be painted on a DrawingArea.
 */
public abstract class AbstractImageset {
	// The imageset file
	protected string imageset_file;

	// A Cairo ImageSurface that will store the images
	protected Cairo.ImageSurface imageset_surface;

	/**
	 * Constructor.
	 */
	public AbstractImageset (string imageset_file) {
		this.imageset_file = imageset_file;
	}

	/**
	 * Clears the imageset.
	 */
	public void clear () {
		this.imageset_file = null;
		this.imageset_surface = null;
	}

	/**
	 * Gets a reference to the imageset surface.
	 */
	public Cairo.ImageSurface get_imageset_surface () {
		return this.imageset_surface;
	}

	/**
	 * Gets a surface containing the image specified by image_id.
	 */
	public abstract Cairo.ImageSurface get_image (int image_id);

	/**
	 * Gets the id of the image placed in the coordinates (x,y).
	 */
	public abstract int get_image_id (int x, int y);

	/**
	 * Gets a matrix containing the ids of the images defined by tiles_rect.
	 */
	public abstract int[,] get_image_ids (Rect tiles_rect);

	/**
	 * Gets the images from the file and loads them into the surface with a desired order.
	 */
	public abstract void load_images ();
}