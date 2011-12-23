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

/**
 * XmlServer is a tool that uses GLib.MarkupParser to parse XML files and convert their
 * string-formatted content to XmlNode instances.
 */
public class XmlParser {
	// Since Vala 0.14 parser started to crash. The solution is declare it as const
	const GLib.MarkupParser parser = {
		opening_tag_callback,
		closing_tag_callback,
		tag_content_callback,
		passthrough_callback,
		error_callback
	};

	/*
	 * Properties
	 */
	private GLib.MarkupParseContext context;
	private int nesting_level = 0;

	/**
	 * A reference to the root XmlNode of the last parsed file.
	 */
	private XmlNode root;

	/*
	 * An auxiliar reference used to point at XmlNodes when parsing.
	 */
	private XmlNode current_ref;

	/**
	 * Instantiates the parse context.
	 */
	public XmlParser () {
		this.context = new GLib.MarkupParseContext (
			this.parser, // MarkupParser instance
			0,		// MarkupParseFlags
			this,   // User data
			null	// User data destroy notifier
		);
	}
	
	/**
	 * Converts the XML file to a hierarchically organized list of XmlNodes.
	 * 
	 * @param path The path to the XML file.
	 */
	public void parse_file (string path) {
		this.root = null;

		try {
//			GLib.File file = GLib.File.new_for_path (path);

			string file_content;

			if (GLib.FileUtils.get_contents (path, out file_content)) {
				file_content = Utils.clean_file_content(file_content);

				this.context.parse (file_content, -1);
			}
		}
		catch (GLib.Error e) {
			stderr.printf ("File '%s' not found", path);
		}	
	}

	/*
	 * This method is called each time the parser finds an opening tag.
	 * 
	 * The parser defines some parameters containing the information related to the tag.
	 */
	private void opening_tag_callback (GLib.MarkupParseContext ctx, string tag_name,
	                                   string[] attr_names, string[] attr_values)
                                      throws GLib.MarkupError {
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
			this.root.prev = null;
			this.root.next = null;
			this.current_ref = this.root;
		}
		/*
		 * Non-root node
		 */
		else {
			XmlNode node = new XmlNode ();
			node.name = tag_name;
			node.attr_names = attr_names;
			node.attr_values = attr_values;
			node.parent = this.current_ref;

			this.current_ref.add_child (node);
			this.current_ref = node;
		}

		this.nesting_level++;
	}

	/*
	 * This method is called each time the parser finds a closing tag.
	 * 
	 * The parser defines some parameters containing the information related to the tag.
	 */
	private void closing_tag_callback (GLib.MarkupParseContext ctx, string tag_name)
                                      throws GLib.MarkupError {
		this.current_ref = this.current_ref.parent;
		this.nesting_level--;
	}

	/*
	 * This method is called each time the parser finds content inside tags.
	 */
	private void tag_content_callback (GLib.MarkupParseContext ctx, string content, size_t content_len)
                                      throws GLib.MarkupError {
		this.current_ref.content = content;
	}

	/*
	 * This method is called each time the parser finds comments, processing instructions
	 * and doctype declarations.
	 */
	private void passthrough_callback (GLib.MarkupParseContext ctx, string passthrough_text, size_t text_len)
                                      throws GLib.MarkupError {
		// Not used yet
	}

	/*
	 * This method is called when the parser finds an error.
	 */
	private void error_callback (GLib.MarkupParseContext ctx, GLib.Error error) {
		// Not used yet
	}

	/**
	 * Returns the root of the tree generated from the XML data.
	 */
	public XmlNode get_root () {
		return this.root;
	}
}