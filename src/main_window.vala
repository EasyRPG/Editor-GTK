/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * main_window.vala
 * Copyright (C) EasyRPG Project 2011-2012
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
	// Reference to Editor
	private Editor editor;

	// Menubar, Toolbar and Statusbar
	private Gtk.MenuBar menubar_main;
	private Gtk.Toolbar toolbar_main;
	private Gtk.Toolbar toolbar_sidebar;
	private Gtk.Statusbar statusbar_tooltip;
	private Gtk.Statusbar statusbar_current_frame;
	private Gtk.Statusbar statusbar_current_position;

	// Maptree, palette and maprender
	public MaptreeTreeView treeview_maptree;
	public TilePaletteDrawingArea drawingarea_palette;
	public MapDrawingArea drawingarea_maprender;
	private Gtk.Paned paned_palette_maptree;

	// Tools
	private Gtk.ToolButton toolitem_eraser;
	private Gtk.ToolButton toolitem_undo;
	private Gtk.ToolButton toolitem_redo;

	// RadioActions
	private Gtk.RadioAction radio_layer;
	private Gtk.RadioAction radio_scale;
	private Gtk.RadioAction radio_drawing_tool;

	// ToggleActions
	private Gtk.ToggleAction toggle_fullscreen;
	private Gtk.ToggleAction toggle_show_title;

	// ActionGroups
	private Gtk.ActionGroup actiongroup_project_open;
	private Gtk.ActionGroup actiongroup_project_closed;



	/**
	 * Builds the main interface.
	 *
	 * @param editor A reference to the Editor class.
	 */
	public MainWindow (Editor editor) {
		/*
		 * Initialize properties
		 */
		this.editor = editor;
		this.set_icon (Resources.load_icon_as_pixbuf ("easyrpg", 48));
		this.set_default_size (500, 400);

		/*
		 * Initialize actions
		 */
		var action_new = new Gtk.Action ("ActionNew", "_New", "Create a new project", null);
		action_new.set_icon_name (Gtk.Stock.NEW);
		var action_open = new Gtk.Action ("ActionOpen", "_Open", "Open a saved project", null);
		action_open.set_icon_name (Gtk.Stock.OPEN);
		var action_close = new Gtk.Action ("ActionClose", "_Close", "Close current project", null);
		action_close.set_icon_name (Gtk.Stock.CLOSE);
		var action_create_game_disk = new Gtk.Action ("ActionCreateGameDisk", "_Create Game Disk", "", null);
		action_create_game_disk.set_icon_name (Resources.ICON_BUILD_PROJECT);
		var action_quit = new Gtk.Action ("ActionQuit", "_Quit", "Quit EasyRPG Game Editor", null);
		action_quit.set_icon_name (Gtk.Stock.QUIT);
		var action_save = new Gtk.Action ("ActionSave", "_Save", "Save all maps changes", null);
		action_save.set_icon_name (Gtk.Stock.SAVE);
		var action_revert = new Gtk.Action ("ActionRevert", "_Revert", "Revert maps to last saved state", null);
		action_revert.set_icon_name (Gtk.Stock.CLEAR);
		var action_lower_layer = new Gtk.RadioAction ("ActionLowerLayer", "_Lower Layer", "Edit lower layer", null, LayerType.LOWER);
		action_lower_layer.set_icon_name (Resources.ICON_LOWER_LAYER);
		var action_upper_layer = new Gtk.RadioAction ("ActionUpperLayer", "_Upper Layer", "Edit upper layer", null, LayerType.UPPER);
		action_upper_layer.set_icon_name (Resources.ICON_UPPER_LAYER);
		var action_event_layer = new Gtk.RadioAction ("ActionEventLayer", "_Event Layer", "Edit map events", null, LayerType.EVENT);
		action_event_layer.set_icon_name (Resources.ICON_EVENT_LAYER);
		var action_11_scale = new Gtk.RadioAction ("Action11Scale", "Zoom 1/_1", "Map zoom 1/1 (Normal)", null, Scale.1_1);
		action_11_scale.set_icon_name (Resources.ICON_11_SCALE);
		var action_12_scale = new Gtk.RadioAction ("Action12Scale", "Zoom 1/_2", "Map zoom 1/2", null, Scale.1_2);
		action_12_scale.set_icon_name (Resources.ICON_12_SCALE);
		var action_14_scale = new Gtk.RadioAction ("Action14Scale", "Zoom 1/_4", "Map zoom 1/4", null, Scale.1_4);
		action_14_scale.set_icon_name (Resources.ICON_14_SCALE);
		var action_18_scale = new Gtk.RadioAction ("Action18Scale", "Zoom 1/_8", "Map zoom 1/8", null, Scale.1_8);
		action_18_scale.set_icon_name (Resources.ICON_18_SCALE);
		var action_database = new Gtk.Action ("ActionDatabase", "_Database", "Database", null);
		action_database.set_icon_name (Resources.ICON_DATABASE);
		var action_material = new Gtk.Action ("ActionMaterial", "_Material", "Import, export and organize your game resources", null);
		action_material.set_icon_name (Resources.ICON_MATERIAL);
		var action_music = new Gtk.Action ("ActionMusic", "_Music", "Play music while you work", null);
		action_music.set_icon_name (Resources.ICON_MUSIC);
		var action_playtest = new Gtk.Action ("ActionPlaytest", "_Play test", "Make a test of your game", null);
		action_playtest.set_icon_name (Resources.ICON_PLAYTEST);
		var action_fullscreen = new Gtk.ToggleAction ("ActionFullScreen", "_Full Screen", "Use full screen in play test mode", null);
		action_fullscreen.set_icon_name (Gtk.Stock.FULLSCREEN);
		var action_show_title = new Gtk.ToggleAction ("ActionShowTitle", "_Show Title", "Show title in play test mode", null);
		action_show_title.set_icon_name (Resources.ICON_TITLE);
		var action_content = new Gtk.Action ("ActionContent", "_Content", "View help contents", null);
		action_content.set_icon_name (Gtk.Stock.HELP);
		var action_about = new Gtk.Action ("ActionAbout", "_About", "See information about this program's current version", null);
		action_about.set_icon_name (Gtk.Stock.ABOUT);
		var action_undo = new Gtk.Action ("ActionUndo", "_Undo", "Undo last change", Gtk.Stock.UNDO);
		var action_redo = new Gtk.Action ("ActionRedo", "_Redo", "Redo last change", Gtk.Stock.REDO);
		var action_select_tool = new Gtk.RadioAction ("ActionSelect", "_Select", "Select a part of the map", null, DrawingTool.SELECT);
		action_select_tool.set_icon_name (Resources.ICON_SELECT);
		var action_zoom_tool = new Gtk.RadioAction ("ActionZoom", "_Zoom", "Increase or decrease map zoom", null, DrawingTool.ZOOM);
		action_zoom_tool.set_icon_name (Resources.ICON_ZOOM);
		var action_pen_tool = new Gtk.RadioAction ("ActionPen", "_Pen", "Draw using a Pen tool (Normal)", null, DrawingTool.PEN);
		action_pen_tool.set_icon_name (Resources.ICON_PEN);
		var action_eraser_tool = new Gtk.RadioAction ("ActionEraserNormal", "_Eraser (Normal)", "Delete tiles with a Pen tool (Normal)", null, DrawingTool.ERASER);
		action_eraser_tool.set_icon_name (Resources.ICON_ERASER);
		var action_rectangle_tool = new Gtk.RadioAction ("ActionRectangle", "_Rectangle", "Draw using a Rectangle tool", null, DrawingTool.RECTANGLE);
		action_rectangle_tool.set_icon_name (Resources.ICON_RECTANGLE);
		var action_circle_tool = new Gtk.RadioAction ("ActionCircle", "_Circle", "Draw using a Circle tool", null, DrawingTool.CIRCLE);
		action_circle_tool.set_icon_name (Resources.ICON_CIRCLE);
		var action_fill_tool = new Gtk.RadioAction ("ActionFill", "_Fill", "Fill a selected area", null, DrawingTool.FILL);
		action_fill_tool.set_icon_name (Resources.ICON_FILL);

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
		action_select_tool.set_group (group_action_drawing_tools);
		action_zoom_tool.join_group (action_select_tool);
		action_pen_tool.join_group (action_select_tool);
		action_eraser_tool.join_group (action_select_tool);
		action_rectangle_tool.join_group (action_select_tool);
		action_circle_tool.join_group (action_select_tool);
		action_fill_tool.join_group (action_select_tool);

		/*
		 * Extra references to a Gtk.RadioAction for each group of RadioActions.
		 * This allows to use group-range methods like get_current_value()
		 */
		this.radio_layer = action_lower_layer;
		this.radio_scale = action_11_scale;
		this.radio_drawing_tool = action_select_tool;

		this.toggle_fullscreen = action_fullscreen;
		this.toggle_show_title = action_show_title;

		/*
		 * Initialize main toolbar
		 */
		var toolitem_new = action_new.create_tool_item () as Gtk.ToolButton;
		var toolitem_open = action_open.create_tool_item () as Gtk.ToolButton;
		var toolitem_close = action_close.create_tool_item () as Gtk.ToolButton;
		var toolitem_create_game_disk = action_create_game_disk.create_tool_item () as Gtk.ToolButton;
		var toolitem_save = action_save.create_tool_item () as Gtk.ToolButton;
		var toolitem_revert = action_revert.create_tool_item () as Gtk.ToolButton;
		var toolitem_lower_layer = action_lower_layer.create_tool_item () as Gtk.ToggleToolButton;
		var toolitem_upper_layer = action_upper_layer.create_tool_item () as Gtk.ToggleToolButton;
		var toolitem_event_layer = action_event_layer.create_tool_item () as Gtk.ToggleToolButton;
		var toolitem_11_scale = action_11_scale.create_tool_item () as Gtk.ToggleToolButton;
		var toolitem_12_scale = action_12_scale.create_tool_item () as Gtk.ToggleToolButton;
		var toolitem_14_scale = action_14_scale.create_tool_item () as Gtk.ToggleToolButton;
		var toolitem_18_scale = action_18_scale.create_tool_item () as Gtk.ToggleToolButton;
		var toolitem_database = action_database.create_tool_item () as Gtk.ToolButton;
		var toolitem_material = action_material.create_tool_item () as Gtk.ToolButton;
		var toolitem_music = action_music.create_tool_item () as Gtk.ToolButton;
		var toolitem_playtest = action_playtest.create_tool_item () as Gtk.ToolButton;
		var toolitem_fullscreen = action_fullscreen.create_tool_item () as Gtk.ToolButton;
		var toolitem_show_title = action_show_title.create_tool_item () as Gtk.ToolButton;
		var toolitem_content = action_content.create_tool_item () as Gtk.ToolButton;

		/*
		 * Initialize drawing toolbar
		 */
		toolitem_undo = action_undo.create_tool_item () as Gtk.ToolButton;
		toolitem_redo = action_redo.create_tool_item () as Gtk.ToolButton;
		var toolitem_select = action_select_tool.create_tool_item () as Gtk.ToolButton;
		var toolitem_zoom = action_zoom_tool.create_tool_item () as Gtk.ToolButton;
		var toolitem_pen = action_pen_tool.create_tool_item () as Gtk.ToolButton;
		this.toolitem_eraser = action_eraser_tool.create_tool_item () as Gtk.ToolButton;
		var toolitem_rectangle = action_rectangle_tool.create_tool_item () as Gtk.ToolButton;
		var toolitem_circle = action_circle_tool.create_tool_item () as Gtk.ToolButton;
		var toolitem_fill = action_fill_tool.create_tool_item () as Gtk.ToolButton;

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
		var menuitem_open = action_open.create_menu_item () as Gtk.ImageMenuItem;
		var menuitem_close = action_close.create_menu_item () as Gtk.ImageMenuItem;
		var menuitem_create_game_disk = action_create_game_disk.create_menu_item () as Gtk.ImageMenuItem;
		var menuitem_quit = action_quit.create_menu_item () as Gtk.ImageMenuItem;
		var menuitem_save = action_save.create_menu_item () as Gtk.ImageMenuItem;
		var menuitem_revert = action_revert.create_menu_item () as Gtk.ImageMenuItem;
		var menuitem_database = action_database.create_menu_item () as Gtk.ImageMenuItem;
		var menuitem_material = action_material.create_menu_item () as Gtk.ImageMenuItem;
		var menuitem_music = action_music.create_menu_item () as Gtk.ImageMenuItem;
		var menuitem_playtest = action_playtest.create_menu_item () as Gtk.ImageMenuItem;
		var menuitem_content = action_content.create_menu_item () as Gtk.ImageMenuItem;
		var menuitem_about = action_about.create_menu_item () as Gtk.ImageMenuItem;

		// Radio items
		var menuitem_lower_layer = action_lower_layer.create_menu_item () as Gtk.CheckMenuItem;
		var menuitem_upper_layer = action_upper_layer.create_menu_item () as Gtk.CheckMenuItem;
		var menuitem_event_layer = action_event_layer.create_menu_item () as Gtk.CheckMenuItem;
		var menuitem_11_scale = action_11_scale.create_menu_item () as Gtk.CheckMenuItem;
		var menuitem_12_scale = action_12_scale.create_menu_item () as Gtk.CheckMenuItem;
		var menuitem_14_scale = action_14_scale.create_menu_item () as Gtk.CheckMenuItem;
		var menuitem_18_scale = action_18_scale.create_menu_item () as Gtk.CheckMenuItem;

		// Toggle items
		var menuitem_fullscreen = action_fullscreen.create_menu_item () as Gtk.CheckMenuItem;
		var menuitem_show_title = action_show_title.create_menu_item () as Gtk.CheckMenuItem;

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
		this.toolbar_sidebar.set_show_arrow (true);
		this.toolbar_sidebar.set_style (Gtk.ToolbarStyle.ICONS);
		this.toolbar_sidebar.set_icon_size (Gtk.IconSize.SMALL_TOOLBAR);

		// Add buttons
		this.toolbar_sidebar.add (toolitem_undo);
		this.toolbar_sidebar.add (toolitem_redo);
		this.toolbar_sidebar.add (new Gtk.SeparatorToolItem());
		this.toolbar_sidebar.add (toolitem_select);
		this.toolbar_sidebar.add (toolitem_zoom);
		this.toolbar_sidebar.add (toolitem_pen);
		this.toolbar_sidebar.add (this.toolitem_eraser);
		this.toolbar_sidebar.add (toolitem_rectangle);
		this.toolbar_sidebar.add (toolitem_circle);
		this.toolbar_sidebar.add (toolitem_fill);

		/*
		 * Initialize widgets
		 */
		var scrolled_palette = new Gtk.ScrolledWindow (null, null);
		var scrolled_maprender = new Gtk.ScrolledWindow (null, null);
		var scrolled_maptree = new Gtk.ScrolledWindow (null, null);

		this.drawingarea_palette = new TilePaletteDrawingArea ();
		this.drawingarea_maprender = new MapDrawingArea (scrolled_maprender);
		this.paned_palette_maptree = new Gtk.Paned (Gtk.Orientation.VERTICAL);
		this.statusbar_tooltip = new Gtk.Statusbar ();
		this.statusbar_current_frame = new Gtk.Statusbar ();
		this.statusbar_current_position = new Gtk.Statusbar ();
		this.treeview_maptree = new MaptreeTreeView ();

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
		scrolled_maptree.add (treeview_maptree);
		scrolled_palette.add_with_viewport (this.drawingarea_palette);
		scrolled_palette.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.ALWAYS);
		scrolled_palette.set_min_content_width (192);
		scrolled_palette.set_policy (Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC);
		scrolled_maprender.add_with_viewport (this.drawingarea_maprender);
		scrolled_maprender.set_policy (Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC);
		
		this.paned_palette_maptree.pack1 (scrolled_palette, true, true);
		this.paned_palette_maptree.pack2 (scrolled_maptree, true, true);

		box_sidebar.pack_start (this.toolbar_sidebar, false, true, 0);
		box_sidebar.pack_start (this.paned_palette_maptree, true, true, 0);

		box_central.pack_start (box_sidebar, false, false);
		box_central.pack_start (scrolled_maprender, true, true);

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
		this.actiongroup_project_open.add_action (action_redo);
		this.actiongroup_project_open.add_action (action_select_tool);
		this.actiongroup_project_open.add_action (action_zoom_tool);
		this.actiongroup_project_open.add_action (action_pen_tool);
		this.actiongroup_project_open.add_action (action_eraser_tool);
		this.actiongroup_project_open.add_action (action_rectangle_tool);
		this.actiongroup_project_open.add_action (action_circle_tool);
		this.actiongroup_project_open.add_action (action_fill_tool);

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
		action_open.activate.connect (this.editor.open_project_from_dialog);
		action_save.activate.connect (this.editor.save_changes);
		action_revert.activate.connect (this.editor.reload_project);
		action_close.activate.connect (this.editor.close_project);
		action_new.activate.connect (this.editor.create_project);

		// Show database dialog
		action_database.activate.connect (this.editor.show_database);

		// Show about dialog
		action_about.activate.connect (this.editor.on_about);

		// Change edition mode
		this.radio_layer.changed.connect (this.on_layer_change);
		this.radio_scale.changed.connect (this.on_scale_change);

		// Map
		this.treeview_maptree.map_selected.connect (this.editor.on_map_selected);
		this.treeview_maptree.map_properties.connect (this.editor.on_map_properties);
		this.treeview_maptree.map_new.connect (this.editor.on_map_new);
		this.treeview_maptree.map_delete.connect (this.editor.on_map_delete);
		this.treeview_maptree.map_shift.connect (this.editor.on_map_shift);

		// Undo and redo
		toolitem_undo.clicked.connect (this.editor.on_undo);
		toolitem_redo.clicked.connect (this.editor.on_redo);

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

		// Close application
		action_quit.activate.connect (on_close);
		this.destroy.connect (on_close);
	}

	public void set_undo_available(bool status) {
		this.toolitem_undo.set_sensitive (status);
	}

	public void set_redo_available(bool status) {
		this.toolitem_redo.set_sensitive (status);
	}

	/**
	 * Returns an int that represents the active layer.
	 */
	public LayerType get_current_layer () {
		return (LayerType) this.radio_layer.get_current_value ();
	}

	/**
	 * Sets the active layer.
	 */
	public void set_current_layer (LayerType layer) {
		this.radio_layer.set_current_value (layer.to_int ());
	}

	/**
	 * Manages the reactions to the layer change.
	 */
	public void on_layer_change () {
		this.update_statusbar_current_frame ();

		// Don't react if the current map is map 0 (game_title)
		if (this.editor.get_current_map_id () == 0) {
			return;
		}

		// Get the current layer
		var layer = (LayerType) this.get_current_layer ();

		// Update the palette
		this.drawingarea_palette.set_current_layer (layer);

		// Update the maprender
		this.drawingarea_maprender.set_current_layer (layer);
	}

	/**
	 * Returns an int that represents the active scale.
	 */
	public Scale get_current_scale () {
		return (Scale) this.radio_scale.get_current_value ();
	}

	/**
	 * Sets the active scale.
	 */
	public void set_current_scale (Scale scale) {
		this.radio_scale.set_current_value (scale.to_int ());
	}

	/**
	 * Manages the reactions to the scale change.
	 */
	public void on_scale_change () {
		// Don't react if the current map is map 0 (game_title)
		if (this.editor.get_current_map_id () == 0) {
			return;
		}

		// Get the current scale
		var scale = (Scale) this.get_current_scale ();

		// Update the maprender
		this.drawingarea_maprender.set_current_scale (scale);
	}

	/**
	 * Returns an int that represents the active drawing tool.
	 */
	public DrawingTool get_current_drawing_tool () {
		return (DrawingTool) this.radio_drawing_tool.get_current_value ();
	}

	/**
	 * Sets the active drawing tool
	 */
	public void set_current_drawing_tool (DrawingTool drawing_tool) {
		this.radio_drawing_tool.set_current_value (drawing_tool.to_int ());
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
	 * Shows the view and makes small fixes to the layout.
	 */
	public new void show_all () {
		base.show_all ();

		// Sets the paned_palette_maptree handle position to middle
		int height = this.paned_palette_maptree.get_allocated_height ();
		this.paned_palette_maptree.set_position (height / 2);
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
}