/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * tool.vala
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
 * The parent class for any Tools used by the Editor (e.g. Pen, Eraser or Zoom).
 */
public abstract class Tool {
	protected MainController controller;
	protected TilePaletteDrawingArea palette;
	protected LayerType current_layer;
	protected Scale current_scale;
	protected Rect current_selection;
	protected int[,] current_selection_data;

	/**
	 * Send if an area should be selected on the map
	 *
	 * @param area the area selected with the Tool
	 */
	public signal void request_selection (Rect area);

	/**
	 * Send if the map's zoom level should be changed
	 *
	 * @param scale the requested zoom level
	 */
	public signal void request_scale (Scale scale);

	/**
	 * Send if the Layer should be changed
	 *
	 * @param layer the layer being requested
	 */
	public signal void request_layer (LayerType layer);

	/**
	 * Called if the left mouse button is pressed somewhere on the map
	 * 
	 * @param cursor The current cursor position on the map in tiles
	 * @param status_layer The layer, which contains informations, which tiles should be rerendered
	 */
	public abstract bool on_button1_pressed (Point cursor, bool[,] status_layer);

	/**
	 * Called if the cursor moves to another tile while the left mouse button is pressed
	 * 
	 * @param cursor The current cursor position on the map in tiles
	 * @param status_layer The layer, which contains informations, which tiles should be rerendered
	 */
	public abstract bool on_button1_motion (Point cursor, bool[,] status_layer);

	/**
	 * Called if the left mouse button is released again
	 * 
	 * @param cursor The current cursor position on the map in tiles
	 * @param current_layer The drawingarea's currently selected layer
	 */
	public abstract bool on_button1_released (Point cursor, int[,] current_layer);

	/**
	 * Called if the right mouse button is pressed somewhere on the map
	 * 
	 * @param cursor The current cursor position on the map in tiles
	 * @param status_layer The layer, which contains informations, which tiles should be rerendered
	 */
	public abstract bool on_button2_pressed (Point cursor, bool[,] status_layer);

	/**
	 * Called if the right mouse button is released again
	 * 
	 * @param cursor The current cursor position on the map in tiles
	 * @param layer The drawingarea's currently selected layer
	 */
	public abstract bool on_button2_released (Point cursor, int[,] layer);

	/**
	 * Called if any key is pressed
	 * 
	 * @param cursor The current cursor position on the map in tiles
	 * @param key Contains the key information as Gdk keyval
	 * @param modifier Contains the key modifier information
	 * @param status_layer The layer, which contains informations, which tiles should be rerendered
	 * @param layer The drawingarea's currently selected layer
	 */
	public abstract bool on_key_pressed (Point cursor, uint key, Gdk.ModifierType modifier, bool[,] status_layer, int[,] layer);

	/**
	 * Called to modify the rendered tile
	 *
	 * @param location The location of the requested tile on the map
	 * @param tile_id set to tile_id to render it. Do not touch to use the current layer's tile
	 */
	public abstract bool on_draw (Point location, out int tile_id);

	/**
	 * Inform which layer is currently edited
	 *
	 * @param layer The layer now being edited
	 */
	public void set_layer (LayerType layer) {
		this.current_layer = layer;
	}

	/**
	 * Inform which zoom level is currently used
	 *
	 * @param scale The zoom level now being used
	 */
	public void set_scale (Scale scale) {
		this.current_scale = scale;
	}

	/**
	 * Inform about current selection
	 *
	 * @param selection The area currently being selected
	 * @param selection_data The data currently being selected
	 */
	public void set_selection (Rect selection, int[,] selection_data) {
		this.current_selection = selection;
		this.current_selection_data = selection_data;
	}
}
