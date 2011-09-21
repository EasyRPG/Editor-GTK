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

public class MainWindow : Gtk.Window {
	/*
	 * Properties
	 */
	private weak MainController controller;
	public Gtk.ActionGroup actiongroup_project_open;
	public Gtk.ActionGroup actiongroup_project_closed;
	private Gtk.DrawingArea drawingarea_maprender;
	private Gtk.DrawingArea drawingarea_palette;
	private Gtk.MenuBar menubar_main;
	private Gtk.Paned paned_palette_maptree;
	private Gtk.ScrolledWindow scrolled_maprender;
	private Gtk.ScrolledWindow scrolled_palette;
	private Gtk.Statusbar statusbar_main;
	private Gtk.Toolbar toolbar_main;
	private Gtk.Toolbar toolbar_sidebar;
	private Gtk.TreeView treeview_maptree;

	private Gtk.RadioAction group_layer;
	private Gtk.RadioAction group_scale;
	private Gtk.RadioAction group_drawing_tool;
	public Gtk.ToggleAction action_fullscreen;
	public Gtk.ToggleAction action_title;	

	/*
	 * Constructor
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
		var	action_create_game_disk = new Gtk.Action ("ActionCreateGameDisk", "_Create Game Disk", "", null);
		var action_save = new Gtk.Action ("ActionSave", "_Save", "Save all maps changes", null);
		var action_revert = new Gtk.Action ("ActionRevert", "_Revert", "Revert maps to last saved state", null);
		var action_lower_layer = new Gtk.RadioAction ("ActionLowerLayer", "_Lower Layer", "Edit lower layer", null, 0);
		var action_upper_layer = new Gtk.RadioAction ("ActionUpperLayer", "_Upper Layer", "Edit upper layer", null, 1);
		var action_event_layer = new Gtk.RadioAction ("ActionEventLayer", "_Event Layer", "Edit map events", null,2);
		var action_11_scale = new Gtk.RadioAction ("Action11Scale", "Zoom 1/_1", "Map zoom 1/1 (Normal)", null, 0);
		var action_12_scale = new Gtk.RadioAction ("Action12Scale", "Zoom 1/_2", "Map zoom 1/2", null, 1);
		var action_14_scale = new Gtk.RadioAction ("Action14Scale", "Zoom 1/_4", "Map zoom 1/4", null, 2);
		var action_18_scale = new Gtk.RadioAction ("Action18Scale", "Zoom 1/_8", "Map zoom 1/8", null, 3);
		var action_database = new Gtk.Action ("ActionDatabase", "_Database", "Database", null);
		var action_material = new Gtk.Action ("ActionMaterial", "_Material", "Import, export and organize your game resources", null);
		var action_music = new Gtk.Action ("ActionMusic", "_Music", "Play music while you work", null);
		var action_playtest = new Gtk.Action ("ActionPlaytest", "_Play test", "Make a test of your game", null);
		this.action_fullscreen = new Gtk.ToggleAction ("ActionFullScreen", "_Full Screen", "Use full screen in play test mode", null);
		this.action_title = new Gtk.ToggleAction ("ActionTitle", "_Title", "Show title in play test mode", null);
		var action_content = new Gtk.Action ("ActionContent", "_Content", "View help contents", null);
		var action_undo = new Gtk.Action ("ActionUndo", "_Undo", "Undo last change", null);
		var action_select = new Gtk.RadioAction ("ActionSelect", "_Select", "Select a part of the map", null, 0);
		var action_zoom = new Gtk.RadioAction ("ActionZoom", "_Zoom", "Increase or decrease map zoom", null, 1);
		var action_pen = new Gtk.RadioAction ("ActionPen", "_Pen", "Draw using a Pen tool (Normal)", null, 2);
		var action_rectangle = new Gtk.RadioAction ("ActionRectangle", "_Rectangle", "Draw using a Rectangle tool", null, 3);
		var action_circle = new Gtk.RadioAction ("ActionCircle", "_Circle", "Draw using a Circle tool", null, 4);
		var action_fill = new Gtk.RadioAction ("ActionFill", "_Fill", "Fill a selected area", null, 5);

		/*
		 * Initialize main toolbar
		 */
		var toolitem_new = new Gtk.ToolButton (new Gtk.Image.from_file ("./share/easyrpg/toolbar/new.png"), "New");
		toolitem_new.set_use_action_appearance (true);
		var toolitem_open = new Gtk.ToolButton(new Gtk.Image.from_file ("./share/easyrpg/toolbar/open.png"), "Open");
		toolitem_open.set_use_action_appearance (true);
		var toolitem_close = new Gtk.ToolButton(new Gtk.Image.from_file ("./share/easyrpg/toolbar/close.png"), "Close");
		toolitem_close.set_use_action_appearance (true);
		var toolitem_create_game_disk = new Gtk.ToolButton(new Gtk.Image.from_file ("./share/easyrpg/toolbar/create_game_disk.png"), "Create Game Disk");
		toolitem_create_game_disk.set_use_action_appearance (true);
		var toolitem_save = new Gtk.ToolButton(new Gtk.Image.from_file ("./share/easyrpg/toolbar/save.png"), "Save all maps");
		toolitem_save.set_use_action_appearance (true);
		var toolitem_revert = new Gtk.ToolButton(new Gtk.Image.from_file ("./share/easyrpg/toolbar/revert.png"), "Revert maps");
		toolitem_revert.set_use_action_appearance (true);
		var toolitem_lower_layer = new Gtk.RadioToolButton ((SList<Gtk.RadioToolButton>) null);
		toolitem_lower_layer.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/lower_layer.png"));
		var toolitem_upper_layer = new Gtk.RadioToolButton(toolitem_lower_layer.get_group ());
		toolitem_upper_layer.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/upper_layer.png"));
		var toolitem_event_layer = new Gtk.RadioToolButton(toolitem_lower_layer.get_group ());
		toolitem_event_layer.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/event_layer.png"));
		var toolitem_11_scale = new Gtk.RadioToolButton((SList<Gtk.RadioToolButton>) null);
		toolitem_11_scale.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/11_scale.png"));
		var toolitem_12_scale = new Gtk.RadioToolButton(toolitem_11_scale.get_group ());
		toolitem_12_scale.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/12_scale.png"));
		var toolitem_14_scale = new Gtk.RadioToolButton(toolitem_11_scale.get_group ());
		toolitem_14_scale.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/14_scale.png"));
		var toolitem_18_scale = new Gtk.RadioToolButton(toolitem_11_scale.get_group ());
		toolitem_18_scale.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/18_scale.png"));
		var toolitem_database = new Gtk.ToolButton (new Gtk.Image.from_file ("./share/easyrpg/toolbar/database.png"), "Database");
		toolitem_database.set_use_action_appearance (true);
		var toolitem_material = new Gtk.ToolButton (new Gtk.Image.from_file ("./share/easyrpg/toolbar/material.png"), "Material");
		toolitem_material.set_use_action_appearance (true);
		var toolitem_music = new Gtk.ToolButton (new Gtk.Image.from_file ("./share/easyrpg/toolbar/music.png"), "Music");
		toolitem_music.set_use_action_appearance (true);
		var toolitem_playtest = new Gtk.ToolButton (new Gtk.Image.from_file ("./share/easyrpg/toolbar/playtest.png"), "Play Test");
		toolitem_playtest.set_use_action_appearance (true);
		var tbtb_fullscreen = new Gtk.ToggleToolButton ();
		tbtb_fullscreen.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/fullscreen.png"));
		tbtb_fullscreen.set_use_action_appearance (true);
		var tbtb_title = new Gtk.ToggleToolButton ();
		tbtb_title.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/title.png"));
		tbtb_title.set_use_action_appearance (true);
		var toolitem_content = new Gtk.ToolButton (new Gtk.Image.from_file ("./share/easyrpg/toolbar/help.png"), "Contents");
		toolitem_content.set_use_action_appearance (true);

		/*
		 * Initialize drawing toolbar
		 */
		var toolitem_undo = new Gtk.ToolButton (new Gtk.Image.from_file ("./share/easyrpg/toolbar/undo.png"), "Undo");
		toolitem_undo.set_use_action_appearance (true);
		var toolitem_select = new Gtk.RadioToolButton ((SList<Gtk.RadioToolButton>) null);
		toolitem_select.set_icon_widget(new Gtk.Image.from_file ("./share/easyrpg/toolbar/select.png"));
		toolitem_select.set_use_action_appearance (true);
		var toolitem_zoom = new Gtk.RadioToolButton (toolitem_select.get_group());
		toolitem_zoom.set_icon_widget(new Gtk.Image.from_file ("./share/easyrpg/toolbar/zoom.png"));
		toolitem_zoom.set_use_action_appearance (true);
		var toolitem_pen = new Gtk.RadioToolButton (toolitem_select.get_group());
		toolitem_pen.set_icon_widget(new Gtk.Image.from_file ("./share/easyrpg/toolbar/pen.png"));
		toolitem_pen.set_use_action_appearance (true);
		var toolitem_rectangle = new Gtk.RadioToolButton (toolitem_select.get_group());
		toolitem_rectangle.set_icon_widget(new Gtk.Image.from_file ("./share/easyrpg/toolbar/rectangle.png"));
		toolitem_rectangle.set_use_action_appearance (true);
		var toolitem_circle = new Gtk.RadioToolButton (toolitem_select.get_group());
		toolitem_circle.set_icon_widget(new Gtk.Image.from_file ("./share/easyrpg/toolbar/circle.png"));
		toolitem_circle.set_use_action_appearance (true);
		var toolitem_fill = new Gtk.RadioToolButton (toolitem_select.get_group());
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
		var menuitem_new = new Gtk.ImageMenuItem ();
		menuitem_new.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/new.png"));
		menuitem_new.set_use_action_appearance (true);
		var menuitem_open = new Gtk.ImageMenuItem ();
		menuitem_open.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/open.png"));
		menuitem_open.set_use_action_appearance (true);
		var menuitem_close = new Gtk.ImageMenuItem ();
		menuitem_close.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/close.png"));
		menuitem_close.set_use_action_appearance (true);
		var menuitem_create_game_disk = new Gtk.ImageMenuItem ();
		menuitem_create_game_disk.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/create_game_disk.png"));
		menuitem_create_game_disk.set_use_action_appearance (true);
		var menuitem_quit = new Gtk.ImageMenuItem ();
		menuitem_quit.set_image (new Gtk.Image.from_stock ("gtk-quit", Gtk.IconSize.MENU));
		menuitem_quit.set_label ("_Quit");
		menuitem_quit.use_underline = true;
		var menuitem_save = new Gtk.ImageMenuItem ();
		menuitem_save.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/save.png"));
		menuitem_save.set_use_action_appearance (true);
		var menuitem_revert = new Gtk.ImageMenuItem ();
		menuitem_revert.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/revert.png"));
		menuitem_revert.set_use_action_appearance (true);
		var menuitem_database = new Gtk.ImageMenuItem ();
		menuitem_database.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/database.png"));
		menuitem_database.set_use_action_appearance (true);
		var menuitem_material = new Gtk.ImageMenuItem ();
		menuitem_material.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/material.png"));
		menuitem_material.set_use_action_appearance (true);
		var menuitem_music = new Gtk.ImageMenuItem ();
		menuitem_music.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/music.png"));
		menuitem_music.set_use_action_appearance (true);
		var menuitem_playtest = new Gtk.ImageMenuItem ();
		menuitem_playtest.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/playtest.png"));
		menuitem_playtest.set_use_action_appearance (true);
		var menuitem_content = new Gtk.ImageMenuItem ();
		menuitem_content.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/help.png"));
		menuitem_content.set_use_action_appearance (true);
		var menuitem_about = new Gtk.ImageMenuItem ();
		menuitem_about.set_image (new Gtk.Image.from_stock ("gtk-about", Gtk.IconSize.MENU));
		menuitem_about.set_label ("_About");
		menuitem_about.use_underline = true;

		// Radio items
		var menuitem_lower_layer = new Gtk.RadioMenuItem ((SList<Gtk.RadioMenuItem>) null);
		menuitem_lower_layer.set_use_action_appearance (true);
		var menuitem_upper_layer = new Gtk.RadioMenuItem(menuitem_lower_layer.get_group ());
		menuitem_upper_layer.set_use_action_appearance (true);
		var menuitem_event_layer = new Gtk.RadioMenuItem(menuitem_lower_layer.get_group ());
		menuitem_event_layer.set_use_action_appearance (true);
		var menuitem_11_scale = new Gtk.RadioMenuItem ((SList<Gtk.RadioMenuItem>) null);
		menuitem_11_scale.set_use_action_appearance (true);
		var menuitem_12_scale = new Gtk.RadioMenuItem(menuitem_11_scale.get_group ());
		menuitem_12_scale.set_use_action_appearance (true);
		var menuitem_14_scale = new Gtk.RadioMenuItem(menuitem_11_scale.get_group ());
		menuitem_14_scale.set_use_action_appearance (true);
		var menuitem_18_scale = new Gtk.RadioMenuItem(menuitem_11_scale.get_group ());
		menuitem_18_scale.set_use_action_appearance (true);

		// Toggle items
		var menuitem_fullscreen = new Gtk.CheckMenuItem();
		menuitem_fullscreen.set_use_action_appearance (true);
		var menuitem_title = new Gtk.CheckMenuItem();
		menuitem_title.set_use_action_appearance (true);

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
		menu_test.add (menuitem_title);
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
		this.toolbar_main.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);

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
		this.toolbar_main.add (tbtb_fullscreen);
		this.toolbar_main.add (tbtb_title);
		this.toolbar_main.add (new Gtk.SeparatorToolItem());
		this.toolbar_main.add (toolitem_content);

		/*
		 * Drawing toolbar layout
		 */
		this.toolbar_sidebar = new Gtk.Toolbar ();
		this.toolbar_sidebar.set_show_arrow (false);
		this.toolbar_sidebar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);

		// Add buttons
		this.toolbar_sidebar.add (toolitem_undo);
		this.toolbar_sidebar.add (new Gtk.SeparatorToolItem());
		this.toolbar_sidebar.add (toolitem_select);
		this.toolbar_sidebar.add (toolitem_zoom);
		this.toolbar_sidebar.add (toolitem_pen);
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
		this.statusbar_main = new Gtk.Statusbar ();
		this.treeview_maptree = new Gtk.TreeView ();
		this.treeview_maptree.set_size_request (-1, 60);

		/*
		 * Initialize boxes
		 */
		var box_main = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
		var box_central = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
		var box_sidebar = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);

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

		box_main.pack_start (this.menubar_main, false, true, 0);
		box_main.pack_start (this.toolbar_main, false, true, 0);
		box_main.pack_start (box_central, true, true, 0);
		box_main.pack_start (this.statusbar_main, false, true, 0);

		this.drawingarea_maprender.is_focus = true;

		this.add (box_main);

		/*
		 * Connect actions and widgets
		 *
		 * IMPORTANT:
		 * Connect toolbar radioitems before menu radioitems causes a Gtk crash
		 */
		// Menu
		menuitem_new.set_related_action (action_new);
		menuitem_open.set_related_action (action_open);
		menuitem_close.set_related_action (action_close);
		menuitem_create_game_disk.set_related_action (action_create_game_disk);
		menuitem_save.set_related_action (action_save);
		menuitem_revert.set_related_action (action_revert);
		menuitem_lower_layer.set_related_action (action_lower_layer);
		menuitem_upper_layer.set_related_action (action_upper_layer);
		menuitem_event_layer.set_related_action (action_event_layer);
		menuitem_11_scale.set_related_action (action_11_scale);
		menuitem_12_scale.set_related_action (action_12_scale);
		menuitem_14_scale.set_related_action (action_14_scale);
		menuitem_18_scale.set_related_action (action_18_scale);
		menuitem_database.set_related_action (action_database);
		menuitem_material.set_related_action (action_material);
		menuitem_music.set_related_action (action_music);
		menuitem_playtest.set_related_action (action_playtest);
		menuitem_content.set_related_action (action_content);
		menuitem_fullscreen.set_related_action (this.action_fullscreen);
		menuitem_title.set_related_action (this.action_title);

		// Main toolbar
		toolitem_new.set_related_action (action_new);
		toolitem_open.set_related_action (action_open);
		toolitem_close.set_related_action (action_close);
		toolitem_create_game_disk.set_related_action (action_create_game_disk);
		toolitem_save.set_related_action (action_save);
		toolitem_revert.set_related_action (action_revert);
		toolitem_lower_layer.set_related_action (action_lower_layer);
		toolitem_upper_layer.set_related_action (action_upper_layer);
		toolitem_event_layer.set_related_action (action_event_layer);
		toolitem_11_scale.set_related_action (action_11_scale);
		toolitem_12_scale.set_related_action (action_12_scale);
		toolitem_14_scale.set_related_action (action_14_scale);
		toolitem_18_scale.set_related_action (action_18_scale);
		toolitem_database.set_related_action (action_database);
		toolitem_material.set_related_action (action_material);
		toolitem_music.set_related_action (action_music);
		toolitem_playtest.set_related_action (action_playtest);
		tbtb_fullscreen.set_related_action (this.action_fullscreen);
		tbtb_title.set_related_action (this.action_title);
		toolitem_content.set_related_action (action_content);

		// Drawing toolbar
		toolitem_undo.set_related_action (action_undo);
		toolitem_select.set_related_action (action_select);
		toolitem_zoom.set_related_action (action_zoom);
		toolitem_pen.set_related_action (action_pen);
		toolitem_rectangle.set_related_action (action_rectangle);
		toolitem_circle.set_related_action (action_circle);
		toolitem_fill.set_related_action (action_fill);

		/*
		 * Create RadioActions Groups
		 */
		// Layer actions
		unowned SList<Gtk.RadioAction> layer_actiongroup = null;
		action_lower_layer.set_group (layer_actiongroup);
		action_upper_layer.set_group (action_lower_layer.get_group ());
		action_event_layer.set_group (action_lower_layer.get_group ());

		// Scale actions
		unowned SList<Gtk.RadioAction> scale_actiongroup = null;
		action_11_scale.set_group (scale_actiongroup);
		action_12_scale.set_group (action_11_scale.get_group ());
		action_14_scale.set_group (action_11_scale.get_group ());
		action_18_scale.set_group (action_11_scale.get_group ());

		// Edition tools actions
		unowned SList<Gtk.RadioAction> editiontools_actiongroup = null;
		action_select.set_group (editiontools_actiongroup);
		action_zoom.set_group (action_select.get_group ());
		action_pen.set_group (action_select.get_group ());
		action_rectangle.set_group (action_select.get_group ());
		action_circle.set_group (action_select.get_group ());
		action_fill.set_group (action_select.get_group ());
		
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
		this.actiongroup_project_open.add_action (this.action_fullscreen);
		this.actiongroup_project_open.add_action (this.action_title);
		this.actiongroup_project_open.add_action (action_undo);
		this.actiongroup_project_open.add_action (action_select);
		this.actiongroup_project_open.add_action (action_zoom);
		this.actiongroup_project_open.add_action (action_pen);
		this.actiongroup_project_open.add_action (action_rectangle);
		this.actiongroup_project_open.add_action (action_circle);
		this.actiongroup_project_open.add_action (action_fill);

		this.actiongroup_project_closed = new Gtk.ActionGroup ("ClosedGroup");
		this.actiongroup_project_closed.add_action (action_new);
		this.actiongroup_project_closed.add_action (action_open);

		/*
		 * Extra references to a Gtk.RadioAction for each group of RadioActions.
		 * This allows to use group-range methods like get_current_value()
		 */
		this.group_layer = action_lower_layer;
		this.group_scale = action_11_scale;
		this.group_drawing_tool = action_select;

		/*
		 * Default values
		 */
		this.actiongroup_project_open.set_sensitive (false);
		this.group_drawing_tool.set_current_value (2); // Pencil

		/*
		 * Connect signals
		 */
		// Open/Close project
		action_open.activate.connect (this.controller.open_project);
		action_close.activate.connect (this.controller.close_project);

		// Show database dialog
		action_database.activate.connect (this.controller.show_database);

		// Show about dialog
		menuitem_about.activate.connect (this.controller.on_about);

		// Close application
		menuitem_quit.activate.connect (on_close);
		this.destroy.connect (on_close);
	}

	/*
	 * Get current layer
	 */
	public int get_current_layer () {
		return this.group_layer.get_current_value ();
	}

	/*
	 * Set current layer
	 */
	public void set_current_layer (int value) {
		this.group_layer.set_current_value (value);
	}

	/*
	 * Get current scale
	 */
	public int get_current_scale () {
		return this.group_scale.get_current_value ();
	}

	/*
	 * Set current scale
	 */
	public void set_current_scale (int value) {
		this.group_scale.set_current_value (value);
	}

	/*
	 * Get current drawing tool
	 */
	public int get_current_drawing_tool () {
		return this.group_drawing_tool.get_current_value ();
	}

	/*
	 * Set current drawing tool
	 */
	public void set_current_drawing_tool (int value) {
		this.group_drawing_tool.set_current_value (value);
	}

	/*
	 * On close
	 */
	[CCode (instance_pos = -1)]
	public void on_close () {
		Gtk.main_quit ();
	}
}