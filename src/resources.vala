/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * resources.vala
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
namespace Resources {
	public const string APP_NAME = "EasyRPG Editor";
	public const string APP_ICON = "easyrpg";
	public const string APP_VERSION = "0.1.0";
	public const string APP_WEBSITE = "http://easy-rpg.org/";
	public const string APP_AUTHORS[] = {"Héctor Barreiro", "Glynn Clements", "Francisco de la Peña", "Aitor García", "Gabriel Kind", "Alejandro Marzini http://vgvgf.com.ar/", "Shin-NiL", "Rikku2000 http://u-ac.net/rikku2000/gamedev/", "Mariano Suligoy", "Paulo Vizcaíno", "Takeshi Watanabe http://takecheeze.blog47.fc2.com/", "Sebastian Reichel http://elektranox.org", null};
	public const string APP_ARTISTS[] = {"Ben Beltran http://nsovocal.com/", "Juan «Magnífico»", "Marina Navarro http://muerteatartajo.blogspot.com/", null};

	public const string ICON_NEW = "old_new";
	public const string ICON_OPEN = "old_open";
	public const string ICON_CLOSE = "old_folder";
	public const string ICON_QUIT = "gtk-quit";
	public const string ICON_BUILD_PROJECT = "old_create_game_disk";
	public const string ICON_SAVE = "old_save";
	public const string ICON_REVERT = "old_revert";
	public const string ICON_LOWER_LAYER = "old_lower_layer";
	public const string ICON_UPPER_LAYER = "old_upper_layer";
	public const string ICON_EVENT_LAYER = "old_event_layer";
	public const string ICON_11_SCALE = "old_11_scale";
	public const string ICON_12_SCALE = "old_12_scale";
	public const string ICON_14_SCALE = "old_14_scale";
	public const string ICON_18_SCALE = "old_18_scale";
	public const string ICON_DATABASE = "old_database";
	public const string ICON_MATERIAL = "old_material";
	public const string ICON_MUSIC = "old_music";
	public const string ICON_PLAYTEST = "old_playtest";
	public const string ICON_FULLSCREEN = "old_fullscreen";
	public const string ICON_TITLE = "old_title";
	public const string ICON_HELP = "old_help";
	public const string ICON_ABOUT = "old_help";
	public const string ICON_UNDO = "old_undo";
	public const string ICON_SELECT = "old_select";
	public const string ICON_ZOOM = "old_zoom";
	public const string ICON_PEN = "old_pen";
	public const string ICON_ERASER = "old_eraser";
	public const string ICON_ERASER_CIRCLE = "old_eraser_circle";
	public const string ICON_ERASER_RECTANGLE = "old_eraser_rectangle";
	public const string ICON_ERASER_FILL = "old_eraser_fill";
	public const string ICON_RECTANGLE = "old_rectangle";
	public const string ICON_CIRCLE = "old_circle";
	public const string ICON_FILL = "old_fill";
	public const string ICON_FOLDER = "old_folder";
	public const string ICON_MAP = "old_map";

	/**
	 * Looks for an icon in the icon theme search path and loads it as a Pixbuf
	 * with the selected size, if found.
	 */
	public Gdk.Pixbuf? load_icon_as_pixbuf (string icon_name, int size = 16) {
		try {
			var icon = Gtk.IconTheme.get_default ().load_icon (icon_name, size, Gtk.IconLookupFlags.NO_SVG);
			return icon;
		}
		catch (Error e) {
			stderr.printf ("Could not load icon '%s'\n", e.message);
			return null;
		}
	}
}
