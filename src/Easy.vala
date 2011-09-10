/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * main_window.vala
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

namespace Easy
{
	public class Position
	{
		public int map_id {get; set; default = 0;}
		public int x {get; set; default = 0;}
		public int y {get; set; default = 0;}
		public Position (int _map_id, int _x, int _y)
		{
			map_id = _map_id;
			x = _x;
			y = _y;
		}
	}
	
	public class Project
	{
		public string game_title {get; set; default = "";}
		public Position party_starting_position;
		public Position boat_starting_position;
		public Position ship_starting_position;
		public Position airship_starting_position;
		public SList<Map> maps;
	}
	public class Map
	{
		enum ScrollType
		{
			SCROLL_NO_LOOP = 0,
			VERTICAL_LOOP_ONLY,
			HORIZONTAL_LOOP_ONLY,
			VERTICAL_AND_HORIZONTAL_LOOP,
		}
		public int chipset_id {get; set; default = 1;}
		private int width {get; set; default = 20;}
		private int height {get;set; default = 15;}
		public int scroll_type {get; set; default = 0;}
		public bool use_panorama {get; set; default = false;}
		public string panorama_filename {get; set;}
		public bool panorama_vloop {get; set; default = false;}
		public bool panorama_hloop {get;set; default = false;}
		public bool panorama_autohscroll {get; set; default = false;}
		public int panorana_autohscroll_speed {get; set; default = 0;}
		public bool panorama_autovscroll {get; set; default = false;}
		public int panorama_autovscroll_speed {get; set; default = 0;}
		public LTileID?[,] lower_layer {get;set; default = null;}
		public int?[] upper_layer {get; set; default = null;}
		public MapEvent?[] events {get; set; default = null;}
		public int savetime {get; set;} /*i dont understand what's it for*/
		public void Map() {}
	}

	public class LTileID
	{
		public string? ID {get; set; default = null;}
	}
	public class MapEvent
	{
		enum Direction
		{
			UP = 0,
			RIGHT,
			DOWN,
			LEFT,
		}
		enum MoveType
		{
			NO_MOVE = 0,
			RANDOM,
			RANDOM_V,
			RANDOM_H,
			GO_TO_PARTY,
			AWAY_FROM_PARTY,
			USE_PATH,
		}
		enum ActivationTrigger
		{
			PRESS_ENTER = 0,
			TOUCH_PARTY,
			TOUCH_EVENT,
			AUTO,
			PARALLEL,
		}
		enum DrawPriority
		{
			BELOW_CHARACTER = 0,
			SAME_AS_CHARACTER,
			ABOVE_CHARACTER,
		}
		enum AnimationType
		{
			NORMAL_NO_STEP = 0,
			NORMAL_WITH_STEP,
			FIXED_NO_STEP,
			FIXED_WITH_STEP,
			FIXED_GRAPHIC,
			TURN_AROUND,
		}
		public string name {get; set; default = "";}
		public int x {get; set; default = 0;}
		public int y {get; set; default = 0;}
		public EventPage[] pages {get; set;}
	}

	public class EventPage
	{
	  /*public 1DimensionalArray trigget_term {get; set;}*/
		public string char_set {get; set; default = "";} /* if empty game uses chipset */
		public int graph_index {get; set; default = 0;} /* 0-7 charset 0-143 chipset */
		public bool half_transparency {get; set; default = false;}
		public int move_type {get; set; default = 0;}
		public int move_frequency {get; set; default = 3;}
		public int activation_trigger {get; set; default = 0;}
		public int draw_priority {get; set; default = 0;}
		public bool pile_with_object {get; set; default = false;}
		public int animation_type {get; set; default = 0;}
	  /*public 1DimensionalArray move_route {get; set;}*/
		public int event_data_size {get; set; default = 0;} /* WTF? */
		public SList<Event>? lines {get {return lines;} set {lines = value;}}
	}

	public abstract class Event
	{   
		enum IDList
		{
			EVENT_ID_LIST_HERE = 0,
			ID2,
			ID3,
			ETC,
		}
		public int? event_id = null;
	}

	public class MessageEvent : Event
	{
		public const int event_id = Event.IDList.ID2;
	}
}