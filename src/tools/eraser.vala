/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * tools/eraser.vala
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
 * The EraserTool used by the Editor
 */
public class EraserTool : EditTool {

	public EraserTool (MainController controller, TilePaletteDrawingArea palette) {
		this.controller = controller;
		this.palette = palette;
	}

	private void eraser (Point cursor, bool[,] status_layer) {
		drawing_layer[cursor.y, cursor.x] = 1;
		status_layer[cursor.y, cursor.x] = false;
	}

	public override bool on_button1_pressed (Point cursor, bool[,] status_layer) {
		this.drawing_layer = new int[status_layer.length[0], status_layer.length[1]];
		eraser (cursor, status_layer);
		return true;
	}

	public override bool on_button1_motion (Point cursor, bool[,] status_layer) {
		eraser (cursor, status_layer);
		return true;
	}

	public override bool on_button2_pressed (Point cursor, bool[,] status_layer) {
		return false;
	}

	public override bool on_button2_released (Point cursor, bool[,] status_layer) {
		return false;
	}

	public override bool on_key_pressed (Point cursor, uint key, Gdk.ModifierType modifier, bool[,] status_layer, int[,] layer) {
		return false;
	}

}
