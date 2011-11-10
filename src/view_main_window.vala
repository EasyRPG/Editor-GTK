/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * view_main_window.vala
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

/**
 * The main window view.
 */
public class MainWindow : Gtk.Window {
	/*
	 * Properties
	 */
	private weak MainController controller;
	private Gtk.DrawingArea drawingarea_maprender;
	private Gtk.DrawingArea drawingarea_palette;
	private Gtk.MenuBar menubar_main;
	private Gtk.Paned paned_palette_maptree;
	private Gtk.ScrolledWindow scrolled_maprender;
	private Gtk.ScrolledWindow scrolled_palette;
	private Gtk.Statusbar statusbar_tooltip;
	private Gtk.Statusbar statusbar_current_frame;
	private Gtk.Statusbar statusbar_current_position;
	private Gtk.Toolbar toolbar_main;
	private Gtk.Toolbar toolbar_sidebar;
	public Gtk.TreeView treeview_maptree;

	private Gtk.Menu menu_eraser;
	private Gtk.ToolButton toolitem_eraser;

	private Gtk.RadioAction radio_layer;
	private Gtk.RadioAction radio_scale;
	private Gtk.RadioAction radio_drawing_tool;

	private Gtk.ToggleAction toggle_fullscreen;
	private Gtk.ToggleAction toggle_show_title;

	private Gtk.ActionGroup actiongroup_project_open;
	private Gtk.ActionGroup actiongroup_project_closed;

	/**
	 * Builds the main interface.
	 * 
	 * @param controller A reference to the controller that launched this view.
	 */
	public MainWindow (MainController controller) {
		/*
		 * Initialize properties
		 */
		this.controller = controller;
		this.set_title ("EasyRPG Editor");

		try {
			this.set_icon (new Gdk.Pixbuf.from_file ("./share/easyrpg/icons/hicolor/48x48/apps/easyrpg.png"));
		}
		catch (Error e) {
			stderr.printf ("Could not load about dialog logo: %s\n", e.message);
		}

		this.set_default_size (500, 400);

		/*
		 * Initialize actions
		 */
		var action_new = new Gtk.Action ("ActionNew", "_New", "Create a new project", null);
		var action_open = new Gtk.Action ("ActionOpen", "_Open", "Open a saved project", null);
		var action_close = new Gtk.Action ("ActionClose", "_Close", "Close current project", null);
		var action_create_game_disk = new Gtk.Action ("ActionCreateGameDisk", "_Create Game Disk", "", null);
		var action_quit = new Gtk.Action ("ActionQuit", "_Quit", "Quit EasyRPG Game Editor", Gtk.Stock.QUIT);
		var action_save = new Gtk.Action ("ActionSave", "_Save", "Save all maps changes", null);
		var action_revert = new Gtk.Action ("ActionRevert", "_Revert", "Revert maps to last saved state", null);
		var action_lower_layer = new Gtk.RadioAction ("ActionLowerLayer", "_Lower Layer", "Edit lower layer", null, LayerType.LOWER);
		var action_upper_layer = new Gtk.RadioAction ("ActionUpperLayer", "_Upper Layer", "Edit upper layer", null, LayerType.UPPER);
		var action_event_layer = new Gtk.RadioAction ("ActionEventLayer", "_Event Layer", "Edit map events", null, LayerType.EVENT);
		var action_11_scale = new Gtk.RadioAction ("Action11Scale", "Zoom 1/_1", "Map zoom 1/1 (Normal)", null, 0);
		var action_12_scale = new Gtk.RadioAction ("Action12Scale", "Zoom 1/_2", "Map zoom 1/2", null, 1);
		var action_14_scale = new Gtk.RadioAction ("Action14Scale", "Zoom 1/_4", "Map zoom 1/4", null, 2);
		var action_18_scale = new Gtk.RadioAction ("Action18Scale", "Zoom 1/_8", "Map zoom 1/8", null, 3);
		var action_database = new Gtk.Action ("ActionDatabase", "_Database", "Database", null);
		var action_material = new Gtk.Action ("ActionMaterial", "_Material", "Import, export and organize your game resources", null);
		var action_music = new Gtk.Action ("ActionMusic", "_Music", "Play music while you work", null);
		var action_playtest = new Gtk.Action ("ActionPlaytest", "_Play test", "Make a test of your game", null);
		var action_fullscreen = new Gtk.ToggleAction ("ActionFullScreen", "_Full Screen", "Use full screen in play test mode", null);
		var action_show_title = new Gtk.ToggleAction ("ActionShowTitle", "_Show Title", "Show title in play test mode", null);
		var action_content = new Gtk.Action ("ActionContent", "_Content", "View help contents", null);
		var action_about = new Gtk.Action ("ActionAbout", "_About", "See information about this program's current version", Gtk.Stock.ABOUT);
		var action_undo = new Gtk.Action ("ActionUndo", "_Undo", "Undo last change", null);
		var action_select = new Gtk.RadioAction ("ActionSelect", "_Select", "Select a part of the map", null, DrawingTool.SELECT);
		var action_zoom = new Gtk.RadioAction ("ActionZoom", "_Zoom", "Increase or decrease map zoom", null, DrawingTool.ZOOM);
		var action_pen = new Gtk.RadioAction ("ActionPen", "_Pen", "Draw using a Pen tool (Normal)", null, DrawingTool.PEN);
		var action_eraser = new Gtk.RadioAction ("ActionEraserNormal", "_Eraser (Normal)", "Delete tiles with a Pen tool (Normal)", null, DrawingTool.ERASER_NORMAL);
		var action_menu_eraser = new Gtk.ToggleAction ("ActionMenuEraser", "Eraser", "Select the eraser shape", null);
		var action_eraser_rectangle = new Gtk.RadioAction ("ActionEraserRectangle", "Eraser R_ectangle", "Delete tiles with a Rectangle tool", null, DrawingTool.ERASER_RECTANGLE);
		var action_eraser_circle = new Gtk.RadioAction ("ActionEraserCircle", "Eraser C_ircle", "Delete tiles with a Circle tool", null, DrawingTool.ERASER_CIRCLE);
		var action_eraser_fill = new Gtk.RadioAction ("ActionEraserFill", "Eraser Fi_ll", "Delete tiles with a Fill tool", null, DrawingTool.ERASER_FILL);
		var action_rectangle = new Gtk.RadioAction ("ActionRectangle", "_Rectangle", "Draw using a Rectangle tool", null, DrawingTool.RECTANGLE);
		var action_circle = new Gtk.RadioAction ("ActionCircle", "_Circle", "Draw using a Circle tool", null, DrawingTool.CIRCLE);
		var action_fill = new Gtk.RadioAction ("ActionFill", "_Fill", "Fill a selected area", null, DrawingTool.FILL);

		/*
		 * Create RadioActions Groups
		 */
		var group_action_layer = new GLib.SList<Gtk.RadioAction> ();
		action_lower_layer.set_group (group_action_layer);
		action_upper_layer.join_group (action_lower_layer);
		action_event_layer.join_group (action_lower_layer);

		var group_action_scale = new GLib.SList<Gtk.RadioAction> ();
		action_11_scale.set_group (group_action_scale);
		action_12_scale.join_group (action_11_scale);
		action_14_scale.join_group (action_11_scale);
		action_18_scale.join_group (action_11_scale);

		var group_action_drawing_tools = new GLib.SList<Gtk.RadioAction> ();
		action_select.set_group (group_action_drawing_tools);
		action_zoom.join_group (action_select);
		action_pen.join_group (action_select);
		action_eraser.join_group (action_select);
		action_eraser_rectangle.join_group (action_select);
		action_eraser_circle.join_group (action_select);
		action_eraser_fill.join_group (action_select);
		action_rectangle.join_group (action_select);
		action_circle.join_group (action_select);
		action_fill.join_group (action_select);

		/*
		 * Extra references to a Gtk.RadioAction for each group of RadioActions.
		 * This allows to use group-range methods like get_current_value()
		 */
		this.radio_layer = action_lower_layer;
		this.radio_scale = action_11_scale;
		this.radio_drawing_tool = action_select;

		this.toggle_fullscreen = action_fullscreen;
		this.toggle_show_title = action_show_title;

		/*
		 * Initialize main toolbar
		 */
		var toolitem_new = action_new.create_tool_item () as Gtk.ToolButton;
		toolitem_new.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/new.png"));
		toolitem_new.set_use_action_appearance (true);
		var toolitem_open = action_open.create_tool_item () as Gtk.ToolButton;
		toolitem_open.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/open.png"));
		toolitem_open.set_use_action_appearance (true);
		var toolitem_close = action_close.create_tool_item () as Gtk.ToolButton;
		toolitem_close.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/close.png"));
		toolitem_close.set_use_action_appearance (true);
		var toolitem_create_game_disk = action_create_game_disk.create_tool_item () as Gtk.ToolButton;
		toolitem_create_game_disk.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/create_game_disk.png"));
		toolitem_create_game_disk.set_use_action_appearance (true);
		var toolitem_save = action_save.create_tool_item () as Gtk.ToolButton;
		toolitem_save.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/save.png"));
		toolitem_save.set_use_action_appearance (true);
		var toolitem_revert = action_revert.create_tool_item () as Gtk.ToolButton;
		toolitem_revert.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/revert.png"));
		toolitem_revert.set_use_action_appearance (true);
		var toolitem_lower_layer = action_lower_layer.create_tool_item () as Gtk.ToggleToolButton;
		toolitem_lower_layer.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/lower_layer.png"));
		toolitem_lower_layer.set_use_action_appearance (true);
		var toolitem_upper_layer = action_upper_layer.create_tool_item () as Gtk.ToggleToolButton;
		toolitem_upper_layer.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/upper_layer.png"));
		toolitem_upper_layer.set_use_action_appearance (true);
		var toolitem_event_layer = action_event_layer.create_tool_item () as Gtk.ToggleToolButton;
		toolitem_event_layer.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/event_layer.png"));
		toolitem_event_layer.set_use_action_appearance (true);
		var toolitem_11_scale = action_11_scale.create_tool_item () as Gtk.ToggleToolButton;
		toolitem_11_scale.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/11_scale.png"));
		toolitem_11_scale.set_use_action_appearance (true);
		var toolitem_12_scale = action_12_scale.create_tool_item () as Gtk.ToggleToolButton;
		toolitem_12_scale.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/12_scale.png"));
		var toolitem_14_scale = action_14_scale.create_tool_item () as Gtk.ToggleToolButton;
		toolitem_14_scale.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/14_scale.png"));
		var toolitem_18_scale = action_18_scale.create_tool_item () as Gtk.ToggleToolButton;
		toolitem_18_scale.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/18_scale.png"));
		var toolitem_database = action_database.create_tool_item () as Gtk.ToolButton;
		toolitem_database.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/database.png"));
		toolitem_database.set_use_action_appearance (true);
		var toolitem_material = action_material.create_tool_item () as Gtk.ToolButton;
		toolitem_material.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/material.png"));
		toolitem_material.set_use_action_appearance (true);
		var toolitem_music = action_music.create_tool_item () as Gtk.ToolButton;
		toolitem_music.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/music.png"));
		toolitem_music.set_use_action_appearance (true);
		var toolitem_playtest = action_playtest.create_tool_item () as Gtk.ToolButton;
		toolitem_playtest.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/playtest.png"));
		toolitem_playtest.set_use_action_appearance (true);
		var toolitem_fullscreen = action_fullscreen.create_tool_item () as Gtk.ToolButton;
		toolitem_fullscreen.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/fullscreen.png"));
		toolitem_fullscreen.set_use_action_appearance (true);
		var toolitem_show_title = action_show_title.create_tool_item () as Gtk.ToolButton;
		toolitem_show_title.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/title.png"));
		toolitem_show_title.set_use_action_appearance (true);
		var toolitem_content = action_content.create_tool_item () as Gtk.ToolButton;
		toolitem_content.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/help.png"));
		toolitem_content.set_use_action_appearance (true);

		/*
		 * Initialize drawing toolbar
		 */
		var toolitem_undo = action_undo.create_tool_item () as Gtk.ToolButton;
		toolitem_undo.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/undo.png"));
		toolitem_undo.set_use_action_appearance (true);
		var toolitem_select = action_select.create_tool_item () as Gtk.ToolButton;
		toolitem_select.set_icon_widget(new Gtk.Image.from_file ("./share/easyrpg/toolbar/select.png"));
		toolitem_select.set_use_action_appearance (true);
		var toolitem_zoom = action_zoom.create_tool_item () as Gtk.ToolButton;
		toolitem_zoom.set_icon_widget(new Gtk.Image.from_file ("./share/easyrpg/toolbar/zoom.png"));
		toolitem_zoom.set_use_action_appearance (true);
		var toolitem_pen = action_pen.create_tool_item () as Gtk.ToolButton;
		toolitem_pen.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/pen.png"));
		toolitem_pen.set_use_action_appearance (true);
		this.toolitem_eraser = action_eraser.create_tool_item () as Gtk.ToolButton;
		this.toolitem_eraser.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/eraser.png"));
		this.toolitem_eraser.set_use_action_appearance (true);
		var toolitem_menu_eraser = action_menu_eraser.create_tool_item () as Gtk.ToggleToolButton;
		toolitem_menu_eraser.set_icon_widget(new Gtk.Arrow(Gtk.ArrowType.DOWN, Gtk.ShadowType.IN));
		toolitem_menu_eraser.set_label ("Eraser");
		toolitem_menu_eraser.set_size_request(15, -1);
		toolitem_menu_eraser.set_use_action_appearance (true);
		this.menu_eraser = new Gtk.Menu ();
		var menuitem_eraser_normal = new Gtk.ImageMenuItem ();
		menuitem_eraser_normal.set_image(new Gtk.Image.from_file ("./share/easyrpg/toolbar/eraser.png"));
		menuitem_eraser_normal.set_use_action_appearance (true);
		menuitem_eraser_normal.set_always_show_image(true);
		var menuitem_eraser_rectangle = new Gtk.ImageMenuItem();
		menuitem_eraser_rectangle.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/eraser_rectangle.png"));
		menuitem_eraser_rectangle.set_use_action_appearance (true);
		menuitem_eraser_rectangle.set_always_show_image(true);
		var menuitem_eraser_circle = new Gtk.ImageMenuItem();
		menuitem_eraser_circle.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/eraser_circle.png"));
		menuitem_eraser_circle.set_use_action_appearance (true);
		menuitem_eraser_circle.set_always_show_image(true);
		var menuitem_eraser_fill = new Gtk.ImageMenuItem();
		menuitem_eraser_fill.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/eraser_fill.png"));
		menuitem_eraser_fill.set_use_action_appearance (true);
		menuitem_eraser_fill.set_always_show_image(true);
		var toolitem_rectangle = action_rectangle.create_tool_item () as Gtk.ToolButton;
		toolitem_rectangle.set_icon_widget(new Gtk.Image.from_file ("./share/easyrpg/toolbar/rectangle.png"));
		toolitem_rectangle.set_use_action_appearance (true);
		var toolitem_circle = action_circle.create_tool_item () as Gtk.ToolButton;
		toolitem_circle.set_icon_widget(new Gtk.Image.from_file ("./share/easyrpg/toolbar/circle.png"));
		toolitem_circle.set_use_action_appearance (true);
		var toolitem_fill = action_fill.create_tool_item () as Gtk.ToolButton;
		toolitem_fill.set_icon_widget(new Gtk.Image.from_file ("./share/easyrpg/toolbar/fill.png"));
		toolitem_fill.set_use_action_appearance (true);

		/*
		 * Initialize menu
		 */
		// Menu items
		var menuitem_project = new Gtk.MenuItem ();
		menuitem_project.use_underline = true;
		menuitem_project.set_label ("_Project");
		var menuitem_map = new Gtk.MenuItem ();
		menuitem_map.use_underline = true;
		menuitem_map.set_label ("_Map");
		var menuitem_tools = new Gtk.MenuItem ();
		menuitem_tools.use_underline = true;
		menuitem_tools.set_label ("_Tools");
		var menuitem_test = new Gtk.MenuItem ();
		menuitem_test.use_underline = true;
		menuitem_test.set_label ("_Test");
		var menuitem_help = new Gtk.MenuItem ();
		menuitem_help.use_underline = true;
		menuitem_help.set_label ("_Help");
		var menuitem_edit = new Gtk.MenuItem ();
		menuitem_edit.use_underline = true;
		menuitem_edit.set_label ("_Edit");
		var menuitem_scale = new Gtk.MenuItem ();
		menuitem_scale.use_underline = true;
		menuitem_scale.set_label ("_Scale");

		// Submenus
		var menu_project = new Gtk.Menu ();
		var menu_map = new Gtk.Menu ();
		var menu_edit = new Gtk.Menu ();
		var menu_scale = new Gtk.Menu ();
		var menu_tools = new Gtk.Menu ();
		var menu_test = new Gtk.Menu ();
		var menu_help = new Gtk.Menu ();

		// Submenu items
		var menuitem_new = action_new.create_menu_item () as Gtk.ImageMenuItem;
		menuitem_new.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/new.png"));
		menuitem_new.set_use_action_appearance (true);
		var menuitem_open = action_open.create_menu_item () as Gtk.ImageMenuItem;
		menuitem_open.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/open.png"));
		menuitem_open.set_use_action_appearance (true);
		var menuitem_close = action_close.create_menu_item () as Gtk.ImageMenuItem;
		menuitem_close.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/close.png"));
		menuitem_close.set_use_action_appearance (true);
		var menuitem_create_game_disk = action_create_game_disk.create_menu_item () as Gtk.ImageMenuItem;
		menuitem_create_game_disk.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/create_game_disk.png"));
		menuitem_create_game_disk.set_use_action_appearance (true);
		var menuitem_quit = action_quit.create_menu_item () as Gtk.ImageMenuItem;
		menuitem_quit.set_image (new Gtk.Image.from_stock ("gtk-quit", Gtk.IconSize.MENU));
		menuitem_quit.set_use_action_appearance(true);
		var menuitem_save = action_save.create_menu_item () as Gtk.ImageMenuItem;
		menuitem_save.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/save.png"));
		menuitem_save.set_use_action_appearance (true);
		var menuitem_revert = action_revert.create_menu_item () as Gtk.ImageMenuItem;
		menuitem_revert.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/revert.png"));
		menuitem_revert.set_use_action_appearance (true);
		var menuitem_database = action_database.create_menu_item () as Gtk.ImageMenuItem;
		menuitem_database.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/database.png"));
		menuitem_database.set_use_action_appearance (true);
		var menuitem_material = action_material.create_menu_item () as Gtk.ImageMenuItem;
		menuitem_material.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/material.png"));
		menuitem_material.set_use_action_appearance (true);
		var menuitem_music = action_music.create_menu_item () as Gtk.ImageMenuItem;
		menuitem_music.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/music.png"));
		menuitem_music.set_use_action_appearance (true);
		var menuitem_playtest = action_playtest.create_menu_item () as Gtk.ImageMenuItem;
		menuitem_playtest.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/playtest.png"));
		menuitem_playtest.set_use_action_appearance (true);
		var menuitem_content = action_content.create_menu_item () as Gtk.ImageMenuItem;
		menuitem_content.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/help.png"));
		menuitem_content.set_use_action_appearance (true);
		var menuitem_about = action_about.create_menu_item () as Gtk.ImageMenuItem;
		menuitem_about.set_image (new Gtk.Image.from_stock ("gtk-about", Gtk.IconSize.MENU));
		menuitem_about.set_use_action_appearance (true);

		// Radio items
		var menuitem_lower_layer = action_lower_layer.create_menu_item () as Gtk.CheckMenuItem;
		menuitem_lower_layer.set_use_action_appearance (true);
		var menuitem_upper_layer = action_upper_layer.create_menu_item () as Gtk.CheckMenuItem;
		menuitem_upper_layer.set_use_action_appearance (true);
		var menuitem_event_layer = action_event_layer.create_menu_item () as Gtk.CheckMenuItem;
		menuitem_event_layer.set_use_action_appearance (true);
		var menuitem_11_scale = action_11_scale.create_menu_item () as Gtk.CheckMenuItem;
		menuitem_11_scale.set_use_action_appearance (true);
		var menuitem_12_scale = action_12_scale.create_menu_item () as Gtk.CheckMenuItem;
		menuitem_12_scale.set_use_action_appearance (true);
		var menuitem_14_scale = action_14_scale.create_menu_item () as Gtk.CheckMenuItem;
		menuitem_14_scale.set_use_action_appearance (true);
		var menuitem_18_scale = action_18_scale.create_menu_item () as Gtk.CheckMenuItem;
		menuitem_18_scale.set_use_action_appearance (true);

		// Toggle items
		var menuitem_fullscreen = action_fullscreen.create_menu_item () as Gtk.CheckMenuItem;
		menuitem_fullscreen.set_use_action_appearance (true);
		var menuitem_show_title = action_show_title.create_menu_item () as Gtk.CheckMenuItem;
		menuitem_show_title.set_use_action_appearance (true);

		/*
		 * Menu layout
		 */
		menu_project.add (menuitem_new);
		menu_project.add (menuitem_open);
		menu_project.add (menuitem_close);
		menu_project.add (new Gtk.SeparatorMenuItem());
		menu_project.add (menuitem_quit);
		menu_map.add (menuitem_save);
		menu_map.add (menuitem_revert);
		menu_map.add (new Gtk.SeparatorMenuItem());
		menu_map.add (menuitem_edit);
		menu_map.add (menuitem_scale);
		menu_edit.add (menuitem_lower_layer);
		menu_edit.add (menuitem_upper_layer);
		menu_edit.add (menuitem_event_layer);
		menu_scale.add (menuitem_11_scale);
		menu_scale.add (menuitem_12_scale);
		menu_scale.add (menuitem_14_scale);
		menu_scale.add (menuitem_18_scale);
		menu_tools.add (menuitem_database);
		menu_tools.add (menuitem_material);
		menu_tools.add (menuitem_music);
		menu_test.add (menuitem_playtest);
		menu_test.add (new Gtk.SeparatorMenuItem ());
		menu_test.add (menuitem_fullscreen);
		menu_test.add (menuitem_show_title);
		menu_help.add (menuitem_content);
		menu_help.add (new Gtk.SeparatorMenuItem ());
		menu_help.add (menuitem_about);

		// Submenus
		menuitem_project.set_submenu (menu_project);
		menuitem_map.set_submenu (menu_map);
		menuitem_edit.set_submenu (menu_edit);
		menuitem_scale.set_submenu (menu_scale);
		menuitem_tools.set_submenu (menu_tools);
		menuitem_test.set_submenu (menu_test);
		menuitem_help.set_submenu (menu_help);

		// Toplevel
		this.menubar_main = new Gtk.MenuBar ();
		this.menubar_main.add (menuitem_project);
		this.menubar_main.add (menuitem_map);
		this.menubar_main.add (menuitem_tools);
		this.menubar_main.add (menuitem_test);
		this.menubar_main.add (menuitem_help);

		/*
		 * Main toolbar layout
		 */
		this.toolbar_main = new Gtk.Toolbar ();
		this.toolbar_main.get_style_context ().add_class (Gtk.STYLE_CLASS_PRIMARY_TOOLBAR);

		// Add buttons
		this.toolbar_main.add (toolitem_new);
		this.toolbar_main.add (toolitem_open);
		this.toolbar_main.add (toolitem_close);
		this.toolbar_main.add (new Gtk.SeparatorToolItem());
		this.toolbar_main.add (toolitem_create_game_disk);
		this.toolbar_main.add (new Gtk.SeparatorToolItem());
		this.toolbar_main.add (toolitem_save);
		this.toolbar_main.add (toolitem_revert);
		this.toolbar_main.add (new Gtk.SeparatorToolItem());
		this.toolbar_main.add (toolitem_lower_layer);
		this.toolbar_main.add (toolitem_upper_layer);
		this.toolbar_main.add (toolitem_event_layer);
		this.toolbar_main.add (new Gtk.SeparatorToolItem());
		this.toolbar_main.add (toolitem_11_scale);
		this.toolbar_main.add (toolitem_12_scale);
		this.toolbar_main.add (toolitem_14_scale);
		this.toolbar_main.add (toolitem_18_scale);
		this.toolbar_main.add (new Gtk.SeparatorToolItem());
		this.toolbar_main.add (toolitem_database);
		this.toolbar_main.add (toolitem_material);
		this.toolbar_main.add (toolitem_music);
		this.toolbar_main.add (new Gtk.SeparatorToolItem());
		this.toolbar_main.add (toolitem_playtest);
		this.toolbar_main.add (new Gtk.SeparatorToolItem());
		this.toolbar_main.add (toolitem_fullscreen);
		this.toolbar_main.add (toolitem_show_title);
		this.toolbar_main.add (new Gtk.SeparatorToolItem());
		this.toolbar_main.add (toolitem_content);

		/*
		 * Drawing toolbar layout
		 */
		this.toolbar_sidebar = new Gtk.Toolbar ();
		this.toolbar_sidebar.set_show_arrow (false);
		this.toolbar_sidebar.get_style_context ().add_class (Gtk.STYLE_CLASS_PRIMARY_TOOLBAR);

		// Add buttons
		this.toolbar_sidebar.add (toolitem_undo);
		this.toolbar_sidebar.add (new Gtk.SeparatorToolItem());
		this.toolbar_sidebar.add (toolitem_select);
		this.toolbar_sidebar.add (toolitem_zoom);
		this.toolbar_sidebar.add (toolitem_pen);
		this.toolbar_sidebar.add (this.toolitem_eraser);
		this.toolbar_sidebar.add (toolitem_menu_eraser);
		this.menu_eraser.add (menuitem_eraser_normal);
		this.menu_eraser.add (menuitem_eraser_rectangle);
		this.menu_eraser.add (menuitem_eraser_circle);
		this.menu_eraser.add (menuitem_eraser_fill);
		this.toolbar_sidebar.add (toolitem_rectangle);
		this.toolbar_sidebar.add (toolitem_circle);
		this.toolbar_sidebar.add (toolitem_fill);

		/*
		 * Initialize widgets
		 */
		this.drawingarea_maprender = new Gtk.DrawingArea ();
		this.drawingarea_palette = new Gtk.DrawingArea ();
		this.paned_palette_maptree = new Gtk.Paned (Gtk.Orientation.VERTICAL);
		this.scrolled_maprender = new Gtk.ScrolledWindow (null, null);
		this.scrolled_palette = new Gtk.ScrolledWindow(null, null);
		this.statusbar_tooltip = new Gtk.Statusbar ();
		this.statusbar_current_frame = new Gtk.Statusbar();
		this.statusbar_current_position = new Gtk.Statusbar();
		this.treeview_maptree = new Gtk.TreeView ();
		this.treeview_maptree.set_size_request (-1, 60);
		this.treeview_maptree.insert_column_with_attributes(-1, "ID", new Gtk.CellRendererText(), "text", 0);
		this.treeview_maptree.insert_column_with_attributes(-1, "Map name", new Gtk.CellRendererText(), "text", 1);
		this.treeview_maptree.set_headers_visible(false);

		/*
		 * Set properties
		 */
		this.statusbar_current_frame.set_size_request(100, 10);
		this.statusbar_current_position.set_size_request(100, 10);

		/*
		 * Initialize boxes
		 */
		var box_main = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var box_central = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		var box_sidebar = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var box_statusbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 5);

		/*
		 * Window layout
		 */
		this.paned_palette_maptree.pack1 (this.scrolled_palette, true, false);
		this.paned_palette_maptree.pack2 (this.treeview_maptree, true, false);

		box_sidebar.pack_start (this.toolbar_sidebar, false, true, 0);
		box_sidebar.pack_start (this.paned_palette_maptree, true, true, 0);

		this.scrolled_palette.add_with_viewport (this.drawingarea_palette);
		this.scrolled_maprender.add_with_viewport (this.drawingarea_maprender);

		box_central.pack_start (box_sidebar, false, false);
		box_central.pack_start (this.scrolled_maprender, true, true);

		box_statusbar.pack_start(statusbar_tooltip, true, true, 0);
		box_statusbar.pack_start(statusbar_current_frame, false, true, 0);
		box_statusbar.pack_start(statusbar_current_position, false, true, 0);

		box_main.pack_start (this.menubar_main, false, true, 0);
		box_main.pack_start (this.toolbar_main, false, true, 0);
		box_main.pack_start (box_central, true, true, 0);
		box_main.pack_start (box_statusbar, false, true, 0);

		this.drawingarea_maprender.is_focus = true;

		this.add (box_main);

		/*
		 * Connect actions and widgets
		 * 
		 * IMPORTANT: Connect toolbar radioitems before menu radioitems causes a Gtk crash
		 */
		this.toolitem_eraser.set_related_action (action_eraser);
		toolitem_menu_eraser.set_related_action (action_menu_eraser);
		menu_eraser.attach_to_widget(toolitem_menu_eraser, null);
		menuitem_eraser_normal.set_related_action (action_eraser);
		menuitem_eraser_rectangle.set_related_action (action_eraser_rectangle);
		menuitem_eraser_circle.set_related_action (action_eraser_circle);
		menuitem_eraser_fill.set_related_action (action_eraser_fill);

		/*
		 * Create ActionGroups
		 */
		this.actiongroup_project_open = new Gtk.ActionGroup("OpenGroup");
		this.actiongroup_project_open.add_action (action_close);
		this.actiongroup_project_open.add_action (action_create_game_disk);
		this.actiongroup_project_open.add_action (action_save);
		this.actiongroup_project_open.add_action (action_revert);
		this.actiongroup_project_open.add_action (action_lower_layer);
		this.actiongroup_project_open.add_action (action_upper_layer);
		this.actiongroup_project_open.add_action (action_event_layer);
		this.actiongroup_project_open.add_action (action_11_scale);
		this.actiongroup_project_open.add_action (action_12_scale);
		this.actiongroup_project_open.add_action (action_14_scale);
		this.actiongroup_project_open.add_action (action_18_scale);
		this.actiongroup_project_open.add_action (action_database);
		this.actiongroup_project_open.add_action (action_material);
		this.actiongroup_project_open.add_action (action_music);
		this.actiongroup_project_open.add_action (action_playtest);
		this.actiongroup_project_open.add_action (action_fullscreen);
		this.actiongroup_project_open.add_action (action_show_title);
		this.actiongroup_project_open.add_action (action_undo);
		this.actiongroup_project_open.add_action (action_select);
		this.actiongroup_project_open.add_action (action_zoom);
		this.actiongroup_project_open.add_action (action_pen);
		this.actiongroup_project_open.add_action (action_eraser);
		this.actiongroup_project_open.add_action (action_eraser_rectangle);
		this.actiongroup_project_open.add_action (action_eraser_circle);
		this.actiongroup_project_open.add_action (action_eraser_fill); 
		this.actiongroup_project_open.add_action (action_rectangle);
		this.actiongroup_project_open.add_action (action_circle);
		this.actiongroup_project_open.add_action (action_fill);

		this.actiongroup_project_closed = new Gtk.ActionGroup ("ClosedGroup");
		this.actiongroup_project_closed.add_action (action_new);
		this.actiongroup_project_closed.add_action (action_open);

		/*
		 * Default values
		 */
		this.actiongroup_project_open.set_sensitive (false);
		this.set_current_layer (LayerType.LOWER);
		this.set_current_drawing_tool (DrawingTool.PEN);

		/*
		 * Connect signals
		 */
		// Open/Close project
		action_open.activate.connect (this.controller.open_project);
		action_close.activate.connect (this.controller.close_project);

		// Show database dialog
		action_database.activate.connect (this.controller.show_database);

		// Show about dialog
		action_about.activate.connect (this.controller.on_about);

		// Change edition mode
		this.radio_layer.changed.connect (this.controller.on_layer_change);

		// Eraser menu callbacks
		toolitem_menu_eraser.clicked.connect (menu_eraser_popup);
		menuitem_eraser_normal.activate.connect		(() => {set_current_drawing_tool(DrawingTool.ERASER_NORMAL);});
		menuitem_eraser_rectangle.activate.connect  (() => {set_current_drawing_tool(DrawingTool.ERASER_RECTANGLE);});
		menuitem_eraser_circle.activate.connect		(() => {set_current_drawing_tool(DrawingTool.ERASER_CIRCLE);});
		menuitem_eraser_fill.activate.connect		(() => {set_current_drawing_tool(DrawingTool.ERASER_FILL);});
		this.menu_eraser.deactivate.connect			(() => {toolitem_menu_eraser.set_active(false);
															var icon = toolitem_menu_eraser.get_icon_widget() as Gtk.Arrow;
															icon.set(Gtk.ArrowType.DOWN, Gtk.ShadowType.IN);});

		/*
		 * Connect menuitem labels to the statusbar
		 * 
		 * Toolitem tooltips shouldn't be connected. They work in a different way.
		 */
		this.connect_menuitem_to_statusbar (menuitem_new);
		this.connect_menuitem_to_statusbar (menuitem_open);
		this.connect_menuitem_to_statusbar (menuitem_close);
		this.connect_menuitem_to_statusbar (menuitem_create_game_disk);
		this.connect_menuitem_to_statusbar (menuitem_save);
		this.connect_menuitem_to_statusbar (menuitem_revert);
		this.connect_menuitem_to_statusbar (menuitem_lower_layer);
		this.connect_menuitem_to_statusbar (menuitem_upper_layer);
		this.connect_menuitem_to_statusbar (menuitem_event_layer);
		this.connect_menuitem_to_statusbar (menuitem_11_scale);
		this.connect_menuitem_to_statusbar (menuitem_12_scale);
		this.connect_menuitem_to_statusbar (menuitem_14_scale);
		this.connect_menuitem_to_statusbar (menuitem_18_scale);
		this.connect_menuitem_to_statusbar (menuitem_database);
		this.connect_menuitem_to_statusbar (menuitem_material);
		this.connect_menuitem_to_statusbar (menuitem_music);
		this.connect_menuitem_to_statusbar (menuitem_playtest);
		this.connect_menuitem_to_statusbar (menuitem_content);
		this.connect_menuitem_to_statusbar (menuitem_fullscreen);
		this.connect_menuitem_to_statusbar (menuitem_show_title);
		this.connect_menuitem_to_statusbar (menuitem_about);
		this.connect_menuitem_to_statusbar (menuitem_quit);
		this.connect_menuitem_to_statusbar (menuitem_eraser_normal);
		this.connect_menuitem_to_statusbar (menuitem_eraser_rectangle);
		this.connect_menuitem_to_statusbar (menuitem_eraser_circle);
		this.connect_menuitem_to_statusbar (menuitem_eraser_fill);

		// Close application
		action_quit.activate.connect (on_close);
		this.destroy.connect (on_close);
	}

	/**
	 * Returns an int that represents the active layer.
	 * 
	 * @return 0 for lower layer; 1 for upper layer; 2 for event layer.
	 */
	public int get_current_layer () {
		return this.radio_layer.get_current_value ();
	}

	/**
	 * Sets the active layer.
	 * 
	 * @param value 0 for lower layer; 1 for upper layer; 2 for event layer.
	 */
	public void set_current_layer (int value) {
		this.radio_layer.set_current_value (value);
	}

	/**
	 * Returns an int that represents the active layer.
	 * 
	 * @return 0 for 1/1; 1 for 1/2; 2 for 1/4; 3 for 1/8.
	 */
	public int get_current_scale () {
		return this.radio_scale.get_current_value ();
	}

	/**
	 * Sets the active scale.
	 * 
	 * @param 0 for 1/1; 1 for 1/2; 2 for 1/4; 3 for 1/8.
	 */
	public void set_current_scale (int value) {
		this.radio_scale.set_current_value (value);
	}

	/**
	 * Returns an int that represents the active drawing tool.
	 * 
	 * @return 0 for select; 1 for zoom; 2 for pen; 3 for rectangle; 4 for circle; 5 for fill.
	 */
	public int get_current_drawing_tool () {
		return this.radio_drawing_tool.get_current_value ();
	}

	/**
	 * Sets the active drawing tool
	 * 
	 * @param 0 for select; 1 for zoom; 2 for pen; 3 for rectangle; 4 for circle; 5 for fill.
	 */
	public void set_current_drawing_tool (int value) {
		Gtk.Image image;
		switch (value){
			case DrawingTool.ERASER_NORMAL:
				Gtk.RadioAction action = actiongroup_project_open.get_action("ActionEraserNormal") as Gtk.RadioAction;
				this.toolitem_eraser.set_related_action(action);
				image = new Gtk.Image.from_file ("./share/easyrpg/toolbar/eraser.png");
				this.toolitem_eraser.set_icon_widget (image);
				image.show();
				break;
			case DrawingTool.ERASER_RECTANGLE:
				Gtk.RadioAction action = actiongroup_project_open.get_action("ActionEraserRectangle") as Gtk.RadioAction;
				this.toolitem_eraser.set_related_action(action);
				image = new Gtk.Image.from_file ("./share/easyrpg/toolbar/eraser_rectangle.png");
				this.toolitem_eraser.set_icon_widget (image);
				image.show();
				break;
			case DrawingTool.ERASER_CIRCLE:
				Gtk.RadioAction action = actiongroup_project_open.get_action("ActionEraserCircle") as Gtk.RadioAction;
				this.toolitem_eraser.set_related_action(action);
				image = new Gtk.Image.from_file ("./share/easyrpg/toolbar/eraser_circle.png");
				this.toolitem_eraser.set_icon_widget (image);
				image.show();
				break;
			case DrawingTool.ERASER_FILL:
				Gtk.RadioAction action = actiongroup_project_open.get_action("ActionEraserFill") as Gtk.RadioAction;
				this.toolitem_eraser.set_related_action(action);
				image = new Gtk.Image.from_file ("./share/easyrpg/toolbar/eraser_fill.png");
				this.toolitem_eraser.set_icon_widget (image);
				image.show();
				break;
			default:
				break;
			}
		this.radio_drawing_tool.set_current_value (value);
	}

	/**
	 * Returns whether the fullscreen option is active or not.
	 */
	public bool get_fullscreen_status () {
		return this.toggle_fullscreen.get_active ();
	}

	/**
	 * Sets the fullscreen option status.
	 */
	public void set_fullscreen_status (bool status) {
		this.toggle_fullscreen.set_active (status);
	}

	/**
	 * Returns whether the show title option is active or not.
	 */
	public bool get_show_title_status () {
		return this.toggle_show_title.get_active ();
	}

	/**
	 * Sets the show title option status.
	 */
	public void set_show_title_status (bool status) {
		this.toggle_show_title.set_active (status);
	}

	/**
	 * Sets the project status (open or closed).
	 *
	 * @param status A string containing "open" or "closed".
	 */
	public void set_project_status (string status) {
		switch (status) {
			case "open":
				this.actiongroup_project_open.set_sensitive (true);
				this.actiongroup_project_closed.set_sensitive (false);
				break;
			case "closed":
				this.actiongroup_project_closed.set_sensitive (true);
				this.actiongroup_project_open.set_sensitive (false);
				break;
			default:
				return;
		}
	}

	/**
	 * Closes this view and quit the application.
	 */
	private void on_close () {
		Gtk.main_quit ();
	}

	private void menu_item_select_cb (Gtk.Widget item){
		string message;
			Gtk.Action action;

			action = item.get_data<Gtk.Action> ("gtk-action");
			return_if_fail (action != null);

			action.get ("tooltip", out message);

		if (message != null){
			this.statusbar_tooltip.push (0, message);
		}
	}

	private void menu_item_deselect_cb (Gtk.Widget item){
		this.statusbar_tooltip.pop (0);
	}
	
	private void connect_menuitem_to_statusbar (Gtk.MenuItem menu_item){
		menu_item.select.connect (this.menu_item_select_cb);
		menu_item.deselect.connect (this.menu_item_deselect_cb);
	}

	public void update_statusbar_current_frame(){
		this.statusbar_current_frame.remove_all(0);
		if (actiongroup_project_open.sensitive){
			switch (this.get_current_layer ()){
				case LayerType.LOWER:
					this.statusbar_current_frame.push (0, "Lower Layer");
					break;
				case LayerType.UPPER:
					this.statusbar_current_frame.push (0, "Upper Layer");
					break;
				case LayerType.EVENT:
					this.statusbar_current_frame.push (0, "Events edition Mode");
					break;
				default:
					break;
			}
		}
	}

	private void menu_eraser_popup(){
		this.menu_eraser.popup (null, null, position_func, 0, 0);
	}

	private void position_func (Gtk.Menu menu, out int x, out int y, out bool push_in){
		var parent = menu.get_attach_widget() as Gtk.ToggleToolButton;
		Gtk.Allocation parent_allocation;
		Gtk.Allocation menu_allocation;
		Gdk.Screen screen = Gdk.Screen.get_default();
		Gdk.Device cursor = Gdk.Display.get_default().get_device_manager().get_client_pointer();

		int current_x, current_y, parent_x, parent_y;

		parent.get_allocation(out parent_allocation);
		menu.get_allocation(out menu_allocation);
		parent.get_pointer(out parent_x, out parent_y);
		cursor.get_position(out screen, out current_x, out current_y);

		x = current_x - parent_x;
		y = current_y - parent_y;

		if (y > (screen.height() - menu_allocation.height) - parent_allocation.height){
			var icon = parent.get_icon_widget() as Gtk.Arrow;
			icon.set(Gtk.ArrowType.UP, Gtk.ShadowType.IN);
			y -= menu_allocation.height;
		} else {
			y += parent_allocation.height;
		}
		if (x > (screen.width() - menu_allocation.width) - parent_allocation.width){
			x -= menu_allocation.width;
			x += parent_allocation.width;
		}
	}
}
