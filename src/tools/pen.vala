/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * tools/pen.vala
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
 * The PenTool used by the Editor
 */
public class PenTool : EditTool {

	public PenTool (Editor editor, TilePaletteDrawingArea palette) {
		this.editor = editor;
		this.palette = palette;
	}

	private bool pen (Point cursor) {
		Rect selected = this.palette.get_selected_rect ().normalize ();

		if (drawing_layer.length[1] <= cursor.x + selected.width)
			selected.width = drawing_layer.length[1] - cursor.x - 1;

		if (drawing_layer.length[0] <= cursor.y + selected.height)
			selected.height = drawing_layer.length[0] - cursor.y - 1;

		for (int y=0; y <= selected.height; y++) {
			for (int x=0; x <= selected.width; x++) {
				int tile = this.palette.position_to_id (selected.x+x, selected.y+y);
				drawing_layer[cursor.y + y, cursor.x + x] = tile;
			}
		}

		return true;
	}

	public override bool on_button1_pressed (Point cursor) {
		this.drawing_layer = new int[height, width];
		return pen (cursor);
	}

	public override bool on_button1_motion (Point cursor) {
		return pen (cursor);
	}

	public override bool on_button2_pressed (Point cursor) {
		return false;
	}

	public override bool on_button2_released (Point cursor, int[,] layer) {
		return false;
	}

	public override bool on_key_pressed (Point cursor, uint key, Gdk.ModifierType modifier, int[,] layer) {
		return false;
	}
}
