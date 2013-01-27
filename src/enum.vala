/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * Copyright (C) 2011 EasyRPG Project
 *
 * License: https://github.com/EasyRPG/Editor/blob/master/COPYING GPL
 *
 * Authors:
 * - Aitor García (Falc) <aitor.falc@gmail.com>
 * - Sebastian Reichel (sre) <sre@ring0.de>
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
}

public enum Direction {
	NONE,
	UP,
	DOWN,
	LEFT,
	RIGHT;
}
