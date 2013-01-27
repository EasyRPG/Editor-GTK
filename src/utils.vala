/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * Copyright (C) 2011-2012 EasyRPG Project
 *
 * License: https://github.com/EasyRPG/Editor/blob/master/COPYING GPL
 *
 * Authors:
 * - Aitor García (Falc) <aitor.falc@gmail.com>
 * - Sebastian Reichel (sre) <sre@ring0.de>
 */

namespace Utils {
	public string clean_file_content (string content) {
		string clean_content = content;
		clean_content = content.replace ("\t", "");
		clean_content = content.replace ("\n", "");

		return clean_content;
	}

	public bool is_in_range (int x, int a, int b) {
		if (a < b)
			return a <= x && x <= b;
		else
			return a >= x && x >= b;
	}
}
