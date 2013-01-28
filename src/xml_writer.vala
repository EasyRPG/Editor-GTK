/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * Copyright (C) 2011-2012 EasyRPG Project
 *
 * License: https://github.com/EasyRPG/Editor/blob/master/COPYING GPL
 *
 * Authors:
 * - Mariano Suligoy (MarianoGNU) <marianognu.easyrpg@gmail.com>
 * - Francisco de la Peña (fdelapena) <fran@fran.cr>
 * - Sebastian Reichel (sre) <sre@ring0.de>
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
	public XmlWriter () {
		this.root = null;
		this.file_content = "";
		this.nesting = 0;
	}

	/*
	 * Set the node to be used as root on the xml file.
	 *
	 * @param root_ref a reference to the XmlNode used as root.
	 */
	public void set_root (XmlNode root_ref) {
		this.root = root_ref;
	}

	public bool generate () {
		if (this.root == null) return false;
		this.nesting = 0;
		this.file_content = """<?xml version="1.0" encoding="UTF-8" ?>""";
		this.next_line ();
		this.write_node(this.root);
		this.file_content += "\n";
		return true;
	}

	private void next_line() {
		this.file_content += "\n";
		for (int i = 0; i < this.nesting; i++)
			this.file_content += "\t";
	}

	private void write_node (XmlNode? node) {
		// End when no more nodes
		if (node == null) return;
		// Open tag
		this.file_content += "<";
		// Attach node name
		this.file_content += node.name;
		// Attach properties
		var property_keys = node.attributes.get_keys ();
		property_keys.sort(strcmp);
		foreach (var key in property_keys)
			this.file_content += " " + key + "=\"" + node.attributes[key] + "\"";
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
		else this.file_content += """ />""";
		// Finish writing if main node has a parent,
		// that way you can write text from subnodes
		if (nesting == 0) return;
		if (node.next != null)
			// Next node? Recursion!
			this.next_line();
			write_node (node.next);
	}

	public void write(string path) throws Error {
		GLib.FileUtils.set_contents (path, this.file_content);
	}
}
