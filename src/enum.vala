/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * enum.vala
 * Copyright (C) EasyRPG Project 2011
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
public enum LayerType {
	LOWER,
	UPPER,
	EVENT;

	public int to_int () {
		switch (this) {
			case LOWER:
				return 0;
			case UPPER:
				return 1;
			case EVENT:
				return 2;
			default:
				error("Unknown layer: %d", this);
		}
	}
}

public enum Scale {
	1_1,
	1_2,
	1_4,
	1_8;

	public int to_int () {
		switch (this) {
			case 1_1:
				return 0;
			case 1_2:
				return 1;
			case 1_4:
				return 2;
			case 1_8:
				return 3;
			default:
				error("Unknown scale: %d", this);
		}
	}
}

public enum DrawingTool {
	SELECT,
	ZOOM,
	PEN,
	ERASER,
	RECTANGLE,
	CIRCLE,
	FILL;

	public int to_int () {
		switch (this) {
			case SELECT:
				return 0;
			case ZOOM:
				return 1;
			case PEN:
				return 2;
			case ERASER:
				return 3;
			case RECTANGLE:
				return 4;
			case CIRCLE:
				return 5;
			case FILL:
				return 6;
			default:
				error("Unknown drawing tool: %d", this);
		}
	}

	public bool needsDrawingLayer () {
		if (this == SELECT || this == ZOOM)
			return false;
		else
			return true;
	}

	public static DrawingTool[] all () {
		return { SELECT, ZOOM, PEN, ERASER, RECTANGLE, CIRCLE, FILL };
	}
}

public enum Direction {
	NONE,
	UP,
	DOWN,
	LEFT,
	RIGHT;
}
