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

public class MainWindow : Gtk.Window
{
	private Gtk.Box box_main;
	private Gtk.MenuBar menubar_main;
	private Gtk.Toolbar toolbar_main;
	private Gtk.Box box_sidebar;
	private Gtk.Toolbar toolbar_sidebar;
	private Gtk.Paned paned_palette_maptree;
	private Gtk.DrawingArea drawingarea_palette;
	private Gtk.TreeView treeview_maptree;
	private Gtk.DrawingArea drawingarea_maprender;
	private Gtk.Statusbar statusbar_main;
	private Gtk.Box box_central;
	private Gtk.ScrolledWindow scrolled_palette;
	private Gtk.ScrolledWindow scrolled_maprender;
	private Gtk.ActionGroup actiongroup_project_open;
	private Gtk.ActionGroup actiongroup_project_closed;

	public MainWindow ()
	{
		try {
			/* MainWindow */

			/* Set Application Properties */
			this.set_title ("EasyRPG Editor");
			this.set_icon (new Gdk.Pixbuf.from_file ("./share/easyrpg/icons/hicolor/48x48/apps/easyrpg.png"));
			this.set_default_size (500, 400);

			/* Generate actions */
			var action_new = new Gtk.Action ("ActionNew", "_New", "Create a new project", null);
			var action_open = new Gtk.Action ("ActionOpen", "_Open", "Open a saved project", null);
			var action_close = new Gtk.Action ("ActionClose", "_Close", "Close current project", null);
			var	action_makegamedisk = new Gtk.Action ("ActionMakeGameDisk", "_Make Game Disk", "", null);
			var action_save = new Gtk.Action ("ActionSave", "_Save", "Save all maps changes", null);
			var action_revert = new Gtk.Action ("ActionRevert", "_Revert", "Revert maps to last saved state", null);
			var action_lowerlayer = new Gtk.RadioAction ("ActionLowerLayer", "_Lower Layer", "Edit lower part of the maps", null, 0);
			var action_upperlayer = new Gtk.RadioAction ("ActionUpperLayer", "_Upper Layer", "Edit upper part of the maps", null, 1);
			var action_eventlayer = new Gtk.RadioAction ("ActionEventLayer", "_Event Layer", "Edit map events", null,2);
			var action_11scale = new Gtk.RadioAction ("Action11scale", "Zoom 1/_1", "Map zoom 1/1 (Normal)", null, 0);
			var action_12scale = new Gtk.RadioAction ("Action12scale", "Zoom 1/_2", "Map zoom 1/2", null, 1);
			var action_14scale = new Gtk.RadioAction ("Action14scale", "Zoom 1/_4", "Map zoom 1/4", null, 2);
			var action_18scale = new Gtk.RadioAction ("Action18scale", "Zoom 1/_8", "Map zoom 1/8", null, 3);
			var action_database = new Gtk.Action ("ActionDataBase", "_Data Base", "Data Base", null);
			var action_material = new Gtk.Action ("ActionMaterial", "_Material", "Import, export and organize your game resources", null);
			var action_music = new Gtk.Action ("ActionMusic", "_Music", "Play music while you work", null);
			var action_playtest = new Gtk.Action ("ActionPlaytest", "_Play test", "Make a test of your game", null);
			var action_fullscreen = new Gtk.ToggleAction ("ActionFullScreen", "_Full Screen", "Use full screen in play test mode", null);
			var action_title = new Gtk.ToggleAction ("ActionTitle", "_Title", "Show title in play test mode", null);
			var action_content = new Gtk.Action ("ActionContent", "_Content", "View help contents", null);
			var action_undo = new Gtk.Action ("ActionUndo", "_Undo", "Undo last change", null);
			var action_select = new Gtk.RadioAction ("ActionSelect", "_Select", "Select a part of the map", null, 0);
			var action_zoom = new Gtk.RadioAction ("ActionZoom", "_Zoom", "Increase or decrease map zoom", null, 1);
			var action_pen = new Gtk.RadioAction ("ActionPen", "_Pen", "Draw using a Pen tool (Normal)", null, 2);
			var action_rectangle = new Gtk.RadioAction ("ActionRectangle", "_Rectangle", "Draw using a Rectangle tool", null, 3);
			var action_circle = new Gtk.RadioAction ("ActionCircle", "_Circle", "Draw using a Circle tool", null, 4);
			var action_fill = new Gtk.RadioAction ("ActionFill", "_Fill", "Fill a selected area", null, 5);
			
			/* Create Main Toolbar buttons and set properties */
			var tbb_new = new Gtk.ToolButton (new Gtk.Image.from_file ("./share/easyrpg/toolbar/new.png") , null);
			tbb_new.set_use_action_appearance (true);
			var tbb_open = new Gtk.ToolButton(new Gtk.Image.from_file ("./share/easyrpg/toolbar/open.png"), "Open");
			tbb_open.set_use_action_appearance (true);
			var tbb_close = new Gtk.ToolButton(new Gtk.Image.from_file ("./share/easyrpg/toolbar/close.png"), "Close");
			tbb_close.set_use_action_appearance (true);
			var tbb_makegamedisk = new Gtk.ToolButton(new Gtk.Image.from_file ("./share/easyrpg/toolbar/makegamedisk.png"), "Make Game Disk");
			tbb_makegamedisk.set_use_action_appearance (true);
			var tbb_save = new Gtk.ToolButton(new Gtk.Image.from_file ("./share/easyrpg/toolbar/save.png"), "Save all maps");
			tbb_save.set_use_action_appearance (true);
			var tbb_revert = new Gtk.ToolButton(new Gtk.Image.from_file ("./share/easyrpg/toolbar/revert.png"), "Revert maps");
			tbb_revert.set_use_action_appearance (true);
			var tbrb_lowerlayer = new Gtk.RadioToolButton ((SList<Gtk.RadioToolButton>) null);
			tbrb_lowerlayer.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/lowerlayer.png"));
			var tbrb_upperlayer = new Gtk.RadioToolButton(tbrb_lowerlayer.get_group ());
			tbrb_upperlayer.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/upperlayer.png"));
			var tbrb_eventlayer = new Gtk.RadioToolButton(tbrb_lowerlayer.get_group ());
			tbrb_eventlayer.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/eventlayer.png"));
			var tbrb_11scale = new Gtk.RadioToolButton((SList<Gtk.RadioToolButton>) null);
			tbrb_11scale.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/11scale.png"));
			var tbrb_12scale = new Gtk.RadioToolButton(tbrb_11scale.get_group ());
			tbrb_12scale.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/12scale.png"));
			var tbrb_14scale = new Gtk.RadioToolButton(tbrb_11scale.get_group ());
			tbrb_14scale.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/14scale.png"));
			var tbrb_18scale = new Gtk.RadioToolButton(tbrb_11scale.get_group ());
			tbrb_18scale.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/18scale.png"));
			var tbb_database = new Gtk.ToolButton (new Gtk.Image.from_file ("./share/easyrpg/toolbar/database.png"), "Data Base");
			tbb_database.set_use_action_appearance (true);
			var tbb_material = new Gtk.ToolButton (new Gtk.Image.from_file ("./share/easyrpg/toolbar/material.png"), "Material");
			tbb_material.set_use_action_appearance (true);
			var tbb_music = new Gtk.ToolButton (new Gtk.Image.from_file ("./share/easyrpg/toolbar/music.png"), "Music");
			tbb_music.set_use_action_appearance (true);
			var tbb_playtest = new Gtk.ToolButton (new Gtk.Image.from_file ("./share/easyrpg/toolbar/playtest.png"), "Play Test");
			tbb_playtest.set_use_action_appearance (true);
			var tbtb_fullscreen = new Gtk.ToggleToolButton ();
			tbtb_fullscreen.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/fullscreen.png"));
			tbtb_fullscreen.set_use_action_appearance (true);
			var tbtb_title = new Gtk.ToggleToolButton ();
			tbtb_title.set_icon_widget (new Gtk.Image.from_file ("./share/easyrpg/toolbar/title.png"));
			tbtb_title.set_use_action_appearance (true);
			var tbb_content = new Gtk.ToolButton (new Gtk.Image.from_file ("./share/easyrpg/toolbar/help.png"), "Contents");
			tbb_content.set_use_action_appearance (true);
			/* Create Edition Toolbar and set properties */
			var tbb_undo = new Gtk.ToolButton (new Gtk.Image.from_file ("./share/easyrpg/toolbar/undo.png"), "Undo");
			tbb_undo.set_use_action_appearance (true);
			var tbrb_select = new Gtk.RadioToolButton ((SList<Gtk.RadioToolButton>) null);
			tbrb_select.set_icon_widget(new Gtk.Image.from_file ("./share/easyrpg/toolbar/select.png"));
			tbrb_select.set_use_action_appearance (true);
			var tbrb_zoom = new Gtk.RadioToolButton (tbrb_select.get_group());
			tbrb_zoom.set_icon_widget(new Gtk.Image.from_file ("./share/easyrpg/toolbar/zoom.png"));
			tbrb_zoom.set_use_action_appearance (true);
			var tbrb_pen = new Gtk.RadioToolButton (tbrb_select.get_group());
			tbrb_pen.set_icon_widget(new Gtk.Image.from_file ("./share/easyrpg/toolbar/pen.png"));
			tbrb_pen.set_use_action_appearance (true);
			var tbrb_rectangle = new Gtk.RadioToolButton (tbrb_select.get_group());
			tbrb_rectangle.set_icon_widget(new Gtk.Image.from_file ("./share/easyrpg/toolbar/rectangle.png"));
			tbrb_rectangle.set_use_action_appearance (true);
			var tbrb_circle = new Gtk.RadioToolButton (tbrb_select.get_group());
			tbrb_circle.set_icon_widget(new Gtk.Image.from_file ("./share/easyrpg/toolbar/circle.png"));
			tbrb_circle.set_use_action_appearance (true);
			var tbrb_fill = new Gtk.RadioToolButton (tbrb_select.get_group());
			tbrb_fill.set_icon_widget(new Gtk.Image.from_file ("./share/easyrpg/toolbar/fill.png"));
			tbrb_fill.set_use_action_appearance (true);

			/* Create Menu and Submenu items */
			/* Create Menu Items */
			var mitem_project = new Gtk.MenuItem ();
			mitem_project.use_underline = true;
			mitem_project.set_label ("_Project");
			var mitem_map = new Gtk.MenuItem ();
			mitem_map.use_underline = true;
			mitem_map.set_label ("_Map");
			var mitem_tools = new Gtk.MenuItem ();
			mitem_tools.use_underline = true;
			mitem_tools.set_label ("_Tools");
			var mitem_test = new Gtk.MenuItem ();
			mitem_test.use_underline = true;
			mitem_test.set_label ("_Test");
			var mitem_help = new Gtk.MenuItem ();
			mitem_help.use_underline = true;
			mitem_help.set_label ("_Help");
			var mitem_edit = new Gtk.MenuItem ();
			mitem_edit.use_underline = true;
			mitem_edit.set_label ("_Edit");
			var mitem_scale = new Gtk.MenuItem ();
			mitem_scale.use_underline = true;
			mitem_scale.set_label ("_Scale");
			/* Create Submenus */
			var menu_project = new Gtk.Menu ();
			var menu_map = new Gtk.Menu ();
			var menu_edit = new Gtk.Menu ();
			var menu_scale = new Gtk.Menu ();
			var menu_tools = new Gtk.Menu ();
			var menu_test = new Gtk.Menu ();
			var menu_help = new Gtk.Menu ();
			/* Create Submenu Items */
			var imgitem_new = new Gtk.ImageMenuItem ();
			imgitem_new.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/new.png"));
			imgitem_new.set_use_action_appearance (true);
			var imgitem_open = new Gtk.ImageMenuItem ();
			imgitem_open.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/open.png"));
			imgitem_open.set_use_action_appearance (true);
			var imgitem_close = new Gtk.ImageMenuItem ();
			imgitem_close.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/close.png"));
			imgitem_close.set_use_action_appearance (true);
			var imgitem_makegamedisk = new Gtk.ImageMenuItem ();
			imgitem_makegamedisk.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/makegamedisk.png"));
			imgitem_makegamedisk.set_use_action_appearance (true);
			var imgitem_quit = new Gtk.ImageMenuItem ();
			imgitem_quit.set_image (new Gtk.Image.from_stock ("gtk-quit", Gtk.IconSize.MENU));
			imgitem_quit.set_label ("_Quit");
			imgitem_quit.use_underline = true;
			var imgitem_save = new Gtk.ImageMenuItem ();
			imgitem_save.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/save.png"));
			imgitem_save.set_use_action_appearance (true);
			var imgitem_revert = new Gtk.ImageMenuItem ();
			imgitem_revert.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/revert.png"));
			imgitem_revert.set_use_action_appearance (true);
			var imgitem_database = new Gtk.ImageMenuItem ();
			imgitem_database.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/database.png"));
			imgitem_database.set_use_action_appearance (true);
			var imgitem_material = new Gtk.ImageMenuItem ();
			imgitem_material.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/material.png"));
			imgitem_material.set_use_action_appearance (true);
			var imgitem_music = new Gtk.ImageMenuItem ();
			imgitem_music.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/music.png"));
			imgitem_music.set_use_action_appearance (true);
			var imgitem_playtest = new Gtk.ImageMenuItem ();
			imgitem_playtest.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/playtest.png"));
			imgitem_playtest.set_use_action_appearance (true);
			var imgitem_content = new Gtk.ImageMenuItem ();
			imgitem_content.set_image (new Gtk.Image.from_file ("./share/easyrpg/toolbar/help.png"));
			imgitem_content.set_use_action_appearance (true);
			var imgitem_about = new Gtk.ImageMenuItem ();
			imgitem_about.set_image (new Gtk.Image.from_stock ("gtk-about", Gtk.IconSize.MENU));
			imgitem_about.set_label ("_About");
			imgitem_about.use_underline = true;
			/* Radio Items */
			var raditem_lowerlayer = new Gtk.RadioMenuItem ((SList<Gtk.RadioMenuItem>) null);
			raditem_lowerlayer.set_use_action_appearance (true);
			var raditem_upperlayer = new Gtk.RadioMenuItem(raditem_lowerlayer.get_group ());
			raditem_upperlayer.set_use_action_appearance (true);
			var raditem_eventlayer = new Gtk.RadioMenuItem(raditem_lowerlayer.get_group ());
			raditem_eventlayer.set_use_action_appearance (true);
			var raditem_11scale = new Gtk.RadioMenuItem ((SList<Gtk.RadioMenuItem>) null);
			raditem_11scale.set_use_action_appearance (true);
			var raditem_12scale = new Gtk.RadioMenuItem(raditem_11scale.get_group ());
			raditem_12scale.set_use_action_appearance (true);
			var raditem_14scale = new Gtk.RadioMenuItem(raditem_11scale.get_group ());
			raditem_14scale.set_use_action_appearance (true);
			var raditem_18scale = new Gtk.RadioMenuItem(raditem_11scale.get_group ());
			raditem_18scale.set_use_action_appearance (true);
			/* Toggle Items */
			var chkitem_fullscreen = new Gtk.CheckMenuItem();
			chkitem_fullscreen.set_use_action_appearance (true);
			var chkitem_title = new Gtk.CheckMenuItem();
			chkitem_title.set_use_action_appearance (true);


			/* Layout menus */
			/* Menu Project */
			menu_project.add (imgitem_new);
			menu_project.add (imgitem_open);
			menu_project.add (imgitem_close);
			menu_project.add (new Gtk.SeparatorMenuItem());
			menu_project.add (imgitem_quit);
			/* Menu Map */
			menu_map.add (imgitem_save);
			menu_map.add (imgitem_revert);
			menu_map.add (new Gtk.SeparatorMenuItem());
			menu_map.add (mitem_edit);
			menu_map.add (mitem_scale);
			/* Menu Edit */
			menu_edit.add (raditem_lowerlayer);
			menu_edit.add (raditem_upperlayer);
			menu_edit.add (raditem_eventlayer);
			/* Menu Scale */
			menu_scale.add (raditem_11scale);
			menu_scale.add (raditem_12scale);
			menu_scale.add (raditem_14scale);
			menu_scale.add (raditem_18scale);
			/* Menu Tools */
			menu_tools.add (imgitem_database);
			menu_tools.add (imgitem_material);
			menu_tools.add (imgitem_music);
			/* Menu Test */
			menu_test.add (imgitem_playtest);
			menu_test.add (new Gtk.SeparatorMenuItem ());
			menu_test.add (chkitem_fullscreen);
			menu_test.add (chkitem_title);
			/* Menu Help */
			menu_help.add (imgitem_content);
			menu_help.add (new Gtk.SeparatorMenuItem ());
			menu_help.add (imgitem_about);
			/* Menu Headers */
			mitem_project.set_submenu (menu_project);
			mitem_map.set_submenu (menu_map);
			mitem_edit.set_submenu (menu_edit);
			mitem_scale.set_submenu (menu_scale);
			mitem_tools.set_submenu (menu_tools);
			mitem_test.set_submenu (menu_test);
			mitem_help.set_submenu (menu_help);
			/* Create and layaut Menu Bar */
			this.menubar_main = new Gtk.MenuBar ();
			this.menubar_main.add (mitem_project);
			this.menubar_main.add (mitem_map);
			this.menubar_main.add (mitem_tools);
			this.menubar_main.add (mitem_test);
			this.menubar_main.add (mitem_help);

			/* Main Toolbar */
			this.toolbar_main = new Gtk.Toolbar ();
			this.toolbar_main.set_show_arrow (false);
			this.toolbar_main.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
			/* Add buttons to the toolbar */
			this.toolbar_main.add (tbb_new);
			this.toolbar_main.add (tbb_open);
			this.toolbar_main.add (tbb_close);
			this.toolbar_main.add (new Gtk.SeparatorToolItem());
			this.toolbar_main.add (tbb_makegamedisk);
			this.toolbar_main.add (new Gtk.SeparatorToolItem());
			this.toolbar_main.add (tbb_save);
			this.toolbar_main.add (tbb_revert);
			this.toolbar_main.add (new Gtk.SeparatorToolItem());
			this.toolbar_main.add (tbrb_lowerlayer);
			this.toolbar_main.add (tbrb_upperlayer);
			this.toolbar_main.add (tbrb_eventlayer);
			this.toolbar_main.add (new Gtk.SeparatorToolItem());
			this.toolbar_main.add (tbrb_11scale);
			this.toolbar_main.add (tbrb_12scale);
			this.toolbar_main.add (tbrb_14scale);
			this.toolbar_main.add (tbrb_18scale);
			this.toolbar_main.add (new Gtk.SeparatorToolItem());
			this.toolbar_main.add (tbb_database);
			this.toolbar_main.add (tbb_material);
			this.toolbar_main.add (tbb_music);
			this.toolbar_main.add (new Gtk.SeparatorToolItem());
			this.toolbar_main.add (tbb_playtest);
			this.toolbar_main.add (new Gtk.SeparatorToolItem());
			this.toolbar_main.add (tbtb_fullscreen);
			this.toolbar_main.add (tbtb_title);
			this.toolbar_main.add (new Gtk.SeparatorToolItem());
			this.toolbar_main.add (tbb_content);

			/* Edition toolbar */
			this.toolbar_sidebar = new Gtk.Toolbar ();
			this.toolbar_sidebar.set_show_arrow (false);
			this.toolbar_sidebar.get_style_context ().add_class (Gtk.STYLE_CLASS_INLINE_TOOLBAR);
			/* Add buttons to the toolbar */
			this.toolbar_sidebar.add (tbb_undo);
			this.toolbar_sidebar.add (new Gtk.SeparatorToolItem());
			this.toolbar_sidebar.add (tbrb_select);
			this.toolbar_sidebar.add (tbrb_zoom);
			this.toolbar_sidebar.add (tbrb_pen);
			this.toolbar_sidebar.add (tbrb_rectangle);
			this.toolbar_sidebar.add (tbrb_circle);
			this.toolbar_sidebar.add (tbrb_fill);
			tbrb_pen.set_active (true);

			/* Create Window Widgets */
			this.drawingarea_palette = new Gtk.DrawingArea ();
			this.drawingarea_maprender = new Gtk.DrawingArea ();
			this.scrolled_palette = new Gtk.ScrolledWindow(null, null);
			this.scrolled_maprender = new Gtk.ScrolledWindow (null, null);
			this.treeview_maptree = new Gtk.TreeView ();
			this.treeview_maptree.set_size_request (-1, 60);
			this.statusbar_main = new Gtk.Statusbar ();

			/* Create Window Containers */
			this.box_central = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
			this.box_sidebar = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
			this.box_main = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
			this.paned_palette_maptree = new Gtk.Paned (Gtk.Orientation.VERTICAL);

			/* Do Layout */
			this.paned_palette_maptree.pack1 (this.scrolled_palette, true, false);
			this.paned_palette_maptree.pack2 (this.treeview_maptree, true, false);
			this.box_sidebar.pack_start (this.toolbar_sidebar, false, true, 0);
			this.box_sidebar.pack_start (this.paned_palette_maptree, true, true, 0);
			this.scrolled_palette.add_with_viewport (drawingarea_palette);
			this.scrolled_maprender.add_with_viewport (drawingarea_maprender);
			this.box_central.pack_start (this.box_sidebar, false, false);
			this.box_central.pack_start (this.scrolled_maprender, true, true);
			this.box_main.pack_start (this.menubar_main, false, true, 0);
			this.box_main.pack_start (this.toolbar_main, false, true, 0);
			this.box_main.pack_start (this.box_central, true, true, 0);
			this.box_main.pack_start (this.statusbar_main, false, true, 0);
			this.drawingarea_maprender.is_focus = true;
			this.add (this.box_main);

			/* Set Actions to Widgets */
			/* MainMenubar */
			/********************************************
			 * IMPORTANT								*
			 * setting toolbar radioitems before menu   *
			 * radioitems causes a crash with Gtk       *
			 ********************************************/
			imgitem_new.set_related_action (action_new);
			imgitem_open.set_related_action (action_open);
			imgitem_close.set_related_action (action_close);
			imgitem_makegamedisk.set_related_action (action_makegamedisk);
			imgitem_save.set_related_action (action_save);
			imgitem_revert.set_related_action (action_revert);
			raditem_lowerlayer.set_related_action (action_lowerlayer);
			raditem_upperlayer.set_related_action (action_upperlayer);
			raditem_eventlayer.set_related_action (action_eventlayer);
			raditem_11scale.set_related_action (action_11scale);
			raditem_12scale.set_related_action (action_12scale);
			raditem_14scale.set_related_action (action_14scale);
			raditem_18scale.set_related_action (action_18scale);
			imgitem_database.set_related_action (action_database);
			imgitem_material.set_related_action (action_material);
			imgitem_music.set_related_action (action_music);
			imgitem_playtest.set_related_action (action_playtest);
			imgitem_content.set_related_action (action_content);
			chkitem_fullscreen.set_related_action (action_fullscreen);
			chkitem_title.set_related_action (action_title);
			/* Main Toolbar */
			tbb_new.set_related_action (action_new);
			tbb_open.set_related_action (action_open);
			tbb_close.set_related_action (action_close);
			tbb_makegamedisk.set_related_action (action_makegamedisk);
			tbb_save.set_related_action (action_save);
			tbb_revert.set_related_action (action_revert);
			tbrb_lowerlayer.set_related_action (action_lowerlayer);
			tbrb_upperlayer.set_related_action (action_upperlayer);
			tbrb_eventlayer.set_related_action (action_eventlayer);
			tbrb_11scale.set_related_action (action_11scale);
			tbrb_12scale.set_related_action (action_12scale);
			tbrb_14scale.set_related_action (action_14scale);
			tbrb_18scale.set_related_action (action_18scale);
			tbb_database.set_related_action (action_database);
			tbb_material.set_related_action (action_material);
			tbb_music.set_related_action (action_music);
			tbb_playtest.set_related_action (action_playtest);
			tbtb_fullscreen.set_related_action (action_fullscreen);
			tbtb_title.set_related_action (action_title);
			tbb_content.set_related_action (action_content);
			/* Sidebar Toolbar */
			tbb_undo.set_related_action (action_undo);
			tbrb_select.set_related_action (action_select);
			tbrb_zoom.set_related_action (action_zoom);
			tbrb_pen.set_related_action (action_pen);
			tbrb_rectangle.set_related_action (action_rectangle);
			tbrb_circle.set_related_action (action_circle);
			tbrb_fill.set_related_action (action_fill);

			/* Create RadioActions Groups */
			/* Group layer actions */
			unowned SList<Gtk.RadioAction> layer_actiongroup = null;
			action_lowerlayer.set_group (layer_actiongroup);
			action_upperlayer.set_group (action_lowerlayer.get_group ());
			action_eventlayer.set_group (action_lowerlayer.get_group ());
			/* Group scale actions */
			unowned SList<Gtk.RadioAction> scale_actiongroup = null;
			action_11scale.set_group (scale_actiongroup);
			action_12scale.set_group (action_11scale.get_group ());
			action_14scale.set_group (action_11scale.get_group ());
			action_18scale.set_group (action_11scale.get_group ());
			/* Group edition tools actions */
			unowned SList<Gtk.RadioAction> editiontools_actiongroup = null;
			action_select.set_group (editiontools_actiongroup);
			action_zoom.set_group (action_select.get_group ());
			action_pen.set_group (action_select.get_group ());
			action_rectangle.set_group (action_select.get_group ());
			action_circle.set_group (action_select.get_group ());
			action_fill.set_group (action_select.get_group ());
			
			/* Create ActionGroups */
			actiongroup_project_open = new Gtk.ActionGroup("OpenGroup");
			actiongroup_project_closed = new Gtk.ActionGroup ("ClosedGroup");
			actiongroup_project_open.add_action (action_close);
			actiongroup_project_open.add_action (action_makegamedisk);
			actiongroup_project_open.add_action (action_save);
			actiongroup_project_open.add_action (action_revert);
			actiongroup_project_open.add_action (action_lowerlayer);
			actiongroup_project_open.add_action (action_upperlayer);
			actiongroup_project_open.add_action (action_eventlayer);
			actiongroup_project_open.add_action (action_11scale);
			actiongroup_project_open.add_action (action_12scale);
			actiongroup_project_open.add_action (action_14scale);
			actiongroup_project_open.add_action (action_18scale);
			actiongroup_project_open.add_action (action_database);
			actiongroup_project_open.add_action (action_material);
			actiongroup_project_open.add_action (action_music);
			actiongroup_project_open.add_action (action_playtest);
			actiongroup_project_open.add_action (action_fullscreen);
			actiongroup_project_open.add_action (action_title);
			actiongroup_project_open.add_action (action_undo);
			actiongroup_project_open.add_action (action_select);
			actiongroup_project_open.add_action (action_zoom);
			actiongroup_project_open.add_action (action_pen);
			actiongroup_project_open.add_action (action_rectangle);
			actiongroup_project_open.add_action (action_circle);
			actiongroup_project_open.add_action (action_fill);
			actiongroup_project_closed.add_action (action_new);
			actiongroup_project_closed.add_action (action_open);

			/* Connections*/
			action_select.changed.connect (on_tool_change); /* Change edition tool */
			imgitem_quit.activate.connect (Gtk.main_quit);  /* Close Application */
			imgitem_about.activate.connect (on_about);		/* Show about dialog */
			
			this.destroy.connect (on_close);
		}
		catch (Error e) {
			stderr.printf ("Could not load UI: %s\n", e.message);
		}
	}

	public void start ()
	{
		this.show_all ();
	}

	private void on_close (Gtk.Widget window)
	{
		Gtk.main_quit ();
	}

	private void on_tool_change ()
	{

	}

	private void on_about ()
	{
		var about_dialog = new Gtk.AboutDialog ();
		about_dialog.set_transient_for (this);
		about_dialog.set_modal (true);
		about_dialog.set_version ("0.1.0");
		about_dialog.set_license_type (Gtk.License.GPL_3_0);
		about_dialog.set_program_name ("EasyRPG Editor");
		about_dialog.set_comments ("A role playing game editor");
		about_dialog.set_website ("http://easy-rpg.org/");
		about_dialog.set_copyright ("© EasyRPG Project 2011");
		about_dialog.set_authors ({"Héctor Barreiro", "Glynn Clements", "Francisco de la Peña", "Aitor García", "Gabriel Kind", "Alejandro Marzini http://vgvgf.com.ar/", "Shin-NiL", "Rikku2000 http://u-ac.net/rikku2000/gamedev/", "Mariano Suligoy", "Paulo Vizcaíno", "Takeshi Watanabe http://takecheeze.blog47.fc2.com/"});
		about_dialog.set_artists ({"Ben Beltran http://nsovocal.com/", "Juan «Magnífico»", "Marina Navarro http://muerteatartajo.blogspot.com/"});
		try {
			var logo = new Gdk.Pixbuf.from_file ("./share/easyrpg/icons/hicolor/48x48/apps/easyrpg.png");
			about_dialog.set_logo (logo);
		}
		catch (Error e)
		{
			stderr.printf ("Could not load about dialog logo: %s\n", e.message);
		}
		about_dialog.run ();
		about_dialog.destroy ();
	}
}
