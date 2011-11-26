/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xml_writer.vala
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

public class XmlWriter {
	/*
	 * Properties
	 */
	private XmlNode? root;
	private string file_content;
	private int nesting;

	/*
	 * Constructor
	 */
	public XmlWriter (){
		this.root = null;
		this.file_content = "";
		this.nesting = 0;
	}

	/*
	 * Set the node to be used as root on the xml file.
	 * 
	 * @param root_ref a reference to the XmlNode used as root.
	 */
	public void set_root (XmlNode root_ref){
		this.root = root_ref;
	}

	public bool write_file (){
		if (this.root == null) return false;
		this.nesting = 0;
		this.file_content = """<?xml version="1.0" encoding="UTF-8" ?>""";
		this.next_line ();
		this.write_node(this.root);
		print (this.file_content + "\n");
		return true;
	}

	private void next_line(){
		this.file_content += "\n";
		for (int i = 0; i < this.nesting; i++)
			this.file_content += "\t";
	}

	private void write_node (XmlNode? node){
		// End when no more nodes
		if (node == null) return;
		// Open tag
		this.file_content += "<";
		// Attach node name
		this.file_content += node.name;
		// Attach properties
		for (int i = 0; i < node.attr_names.length; i++)
			this.file_content += " " + node.attr_names[i] + "=\"" + node.attr_values[i] + "\"";
		// First check for childrens
		if (node.children != null){
			// End of aperture tag
			this.file_content += ">";
			this.nesting++;
			this.next_line ();
			// Recursion!
			this.write_node(node.children);
			this.nesting--;
			this.next_line();
			// Close node
			this.file_content += "</" + node.name + ">";
		}
		// if not we check for node content
		else if (node.content != ""){
			// End of aperture tag
			this.file_content += ">";
			// Write content
			this.file_content += node.content;
			// Close node
			this.file_content += "</" + node.name + ">";
		}
		// No children nor content? Inline tag
		else this.file_content += """/>""";
		// Finish writing if main node has a parent,
		// that way you can write text from subnodes
		if (nesting == 0) return;
		if (node.next != null)
			// Next node? Recursion!
			this.next_line();
			write_node (node.next);
	}

	public bool save_to_file(string path){
		try {
			GLib.File file = GLib.File.new_for_path (path);

			string file_content;

			GLib.FileUtils.set_contents (path, this.file_content);
			return true;
		}
		catch (GLib.Error e) {
			stderr.printf ("Coudn't save file: %s", path);
			return false;
		}
	}
}