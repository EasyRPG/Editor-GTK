/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * tools/rectangle.vala
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
 * The RectangleTool used by the Editor
 */
public class RectangleTool : EditTool {
	Point start;
	Point old;

	public RectangleTool (MainController controller, TilePaletteDrawingArea palette) {
		this.controller = controller;
		this.palette = palette;
	}

	public override bool on_button1_pressed (Point cursor) {
		this.drawing_layer = new int[height, width];
		this.start = cursor;
		this.old   = cursor;

		drawing_layer[cursor.y, cursor.x] = this.palette.position_to_id(this.palette.getSelected ().x, this.palette.getSelected ().y);

		return true;
	}

	public override bool on_button1_motion (Point cursor) {
		Rect selected = this.palette.getSelected ().normalize ();

		/* old area */
		Rect area_old = Rect (start.x, start.y, old.x-start.x, old.y-start.y).normalize ();
		area_old.width++;
		area_old.height++;

		/* new area */
		Rect area_new = Rect (start.x, start.y, cursor.x-start.x, cursor.y-start.y).normalize ();
		area_new.width++;
		area_new.height++;

		/* merged */
		Rect area_all = area_new.union (area_old);

		/* recheck all involved tiles */
		foreach(Point p in area_all) {
			if (p in area_new) {
				int off_x = (p.x - area_new.x) % (selected.width+1);
				int off_y = (p.y - area_new.y) % (selected.height+1);
				drawing_layer[p.y,p.x] = this.palette.position_to_id (selected.x+off_x, selected.y+off_y);
			} else {
				drawing_layer[p.y,p.x] = 0;
			}
		}

		old = cursor;
		return true;
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
