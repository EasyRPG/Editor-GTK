/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xml_parser.vala
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

using GLib;

public class XmlParser {
	/*
	 * Properties
	 */
	public MarkupParser parser;
	public MarkupParseContext context;
	public XmlNode root;
	public XmlNode current_ref;
	private int nesting_level = 0;

	/*
	 * Constructor
	 */
	public XmlParser () {
		// Initialize the parser and its callback methods
		this.parser = {
			opening_tag_callback,
			closing_tag_callback,
			tag_content_callback,
			passthrough_callback,
			error_callback
		};

		// Initialize the parse context
		this.context = new MarkupParseContext (
			this.parser, // MarkupParser instance
			0,		// MarkupParseFlags
			this,   // User data
			null	// User data destroy notifier
		);
	}

	/*
	 * Parse file
	 */
	public void parse_file (string path) {
		try {
			File file = File.new_for_path (path);
			
			string file_content;
			file.load_contents (null, out file_content);

			// FIXME: Move these replaces to our own replace method?
			file_content = file_content.replace ("\t", "");
			file_content = file_content.replace ("\n", "");

			this.context.parse (file_content, -1);
		}
		catch (Error e) {
			stderr.printf ("File '%s' not found", path);
		}	
	}

	/*
	 * Opening tag callback
	 */
	private void opening_tag_callback (MarkupParseContext ctx, string tag_name,
	                                   string[] at_names, string[] at_values)
                                      throws MarkupError {
		/*
		 * Root Node
		 *
		 * Only one root level block is parsed. Any other root level block
		 * found in the file is automatically ignored.
		 */
		if(this.nesting_level == 0) {
			// If a root block was already parsed, ignore the rest of the file
			if(this.root != null && this.root.name != "") {
				ctx.end_parse ();
				return;
			}

			this.root = new XmlNode ();
			this.root.name = tag_name;
			this.root.parent = null;
			this.current_ref = this.root;
		}
		/*
		 * Non-root node
		 */
		else {
			XmlNode node = new XmlNode ();
			node.name = tag_name;
			node.attr_names = at_names;
			node.attr_values = at_values;

			// Add the node as child and update current_ref
			this.current_ref.add_children (node);
			node.parent = this.current_ref;
			this.current_ref = node;
		}

		this.nesting_level++;
	}

	/*
	 * Closing tag callback
	 */
	private void closing_tag_callback (MarkupParseContext ctx, string tag_name)
                                      throws MarkupError {
		this.current_ref = this.current_ref.parent;
		this.nesting_level--;
	}

	/*
	 * Tag content callback
	 */
	private void tag_content_callback (MarkupParseContext ctx, string content,
	                                   size_t content_len) throws MarkupError {
		this.current_ref.content = content;
	}

	/*
	 * Passthrough callback
	 */
	private void passthrough_callback (MarkupParseContext ctx,
	                                   string passthrough_text, size_t text_len)
                                      throws MarkupError {
		// Not used yet
	}

	/*
	 * Error callback
	 */
	private void error_callback (MarkupParseContext ctx, Error error) {
		// Not used yet
	}

	/*
	 * Get node
	 * 
	 * A recursive method that returns the wanted node if found or null if not.
	 */
	public XmlNode get_node (string name, XmlNode? node_ref = null) {
		XmlNode? wanted_node = null;

		/* 
		 * The first time get_node is called, node_ref should be null. This
		 * connects it to the root.
		 */
		if(node_ref == null) {
			node_ref = root;
		}

		/*
		 * If this node is the one we are looking for, return it
		 */
		if(node_ref.name == name) {
			return node_ref;
		}
		/*
		 * Else, check the children nodes
		 */
		else {
			int i = 0;
			while(i < node_ref.get_children_num ()) {
				// Recursion!
				wanted_node = this.get_node (name, node_ref.get_child(i));

				// If the wanted node was found, stop the process
				if(wanted_node != null) {
					break;
				}

				i++;
			}

			return wanted_node;
		}
	}
}