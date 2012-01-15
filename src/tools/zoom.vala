/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * tools/zoom.vala
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
 * The ZoomTool used by the Editor
 */
public class ZoomTool : Tool {
	public ZoomTool (MainController controller, TilePaletteDrawingArea palette) {
		this.controller = controller;
		this.palette = palette;
	}

	public override bool on_button1_pressed (Point cursor, bool[,] status_layer) {
		if (current_scale > Scale.1_1)
			request_scale (current_scale-1);

		return true;
	}

	public override bool on_button1_motion (Point cursor, bool[,] status_layer) {
		return false;
	}

	public override bool on_button1_released (Point cursor, int[,] layer) {
		return false;
	}

	public override bool on_button2_pressed (Point cursor, bool[,] status_layer) {
		if (current_scale < Scale.1_8)
			request_scale (current_scale+1);

		return true;
	}

	public override bool on_button2_released (Point cursor, bool[,] status_layer) {
		return false;
	}

	public override bool on_key_pressed (Point cursor, uint key, Gdk.ModifierType modifier, bool[,] status_layer, int[,] layer) {
		return false;
	}

	public override bool on_draw (Point location, out int tile_id) {
		tile_id = 0;
		return false;
	}

}
