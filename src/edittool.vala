/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * edittool.vala
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
 * The parent class for EditTools used by the Editor (e.g. Pen or Eraser).
 */
public abstract class EditTool : Tool {
	protected int[,] drawing_layer;
	public bool is_eraser {get; protected set; default = false;}

	/**
	 * Called to modify the rendered tile
	 *
	 * @param location The location of the requested tile on the map
	 * @param tile_id set to tile_id to render it. Do not touch to use the current layer's tile
     *
	 */
	public override bool on_draw (Point tile, out int tile_id) {
		tile_id = 0;

		/* check if anything is edited */
		if (drawing_layer == null)
			return false;

		int new_id = drawing_layer[tile.y, tile.x];

		if (new_id != 0) {
			if (is_eraser) {
				tile_id = 0;
				return true;
			}
			else {
				tile_id = new_id;
				return true;
			}
		}

		/* no match */
		tile_id = 0;
		return false;
	}

	/**
	 * Called if the left mouse button is released again
	 * 
	 * @param cursor The current cursor position on the map in tiles
	 * @param layer The drawingarea's currently selected layer
	 */
	public override bool on_button1_released (Point cursor, int[,] layer) {
		int height  = drawing_layer.length[0];
		int width   = drawing_layer.length[1];
		int changes = 0;
		weak int[,] map_layer;

		switch (current_layer) {
			case LayerType.LOWER:
				map_layer = editor.get_map ().lower_layer;
				break;
			case LayerType.UPPER:
				map_layer = editor.get_map ().upper_layer;
				break;
			default:
				warning ("unsupported Layer!");
				return false;
		}

		for (int y=0; y < height; y++) {
			for (int x=0; x < width; x++) {
				if (drawing_layer[y,x] != 0) {
					/* update layer and put diff into drawing_layer */
					if (this.is_eraser) {
						drawing_layer[y,x] = layer[y,x];
						map_layer[y,x] = 0;
						layer[y,x] = 0;
					} else {
						layer[y,x] = drawing_layer[y,x];
						drawing_layer[y,x] = map_layer[y,x] - drawing_layer[y,x];
						map_layer[y,x] = layer[y,x];
					}

					/* only count as difference if something changed */
					if (drawing_layer[y,x] != 0)
						changes++;
				}
			}
		}

		/* avoid empty edits on the ActionStack (they are useless) */
		if (changes == 0)
			return true;

		var action = new UndoManager.MapEditAction (current_layer, drawing_layer, changes);
		editor.get_map_changes ().push (action);

		/* clean drawing layer */
		drawing_layer = null;

		return true;
	}
}
