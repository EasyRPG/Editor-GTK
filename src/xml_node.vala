/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * xml_node.vala
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
 * Represents an XML element.
 * 
 * An XmlNode instance stores the name, content, attributes and relationships of an XML element.
 * 
 * More information can be found at [[http://en.wikipedia.org/wiki/XML#Key_terminology]]
 */
public class XmlNode {
	/**
	 * The name of the XML element.
	 *
	 * For example:
	 * If the XML element is <width>30</width>, the name would be "width". 
	 */
	public string name;

	/**
	 * The content of the XML element.
	 * 
	 * For example:
	 * If the XML element is <width>30</width>, the content would be "30".
	 */
	public string content;

	/**
	 * A reference to the parent node.
	 */
	public weak XmlNode parent;

	/**
	 * A reference to the first child.
	 * 
	 * The rest of the children should be accessed using next ().
	 */
	public XmlNode children;

	/**
	 * A reference to the next node.
	 */
	public XmlNode next;

	/**
	 * A reference to the previous node.
	 */
	public weak XmlNode prev;

	/**
	 * An array containing the attribute names of the element.
	 */
	public string[] attr_names;

	/**
	 * An array containing the attribute values of the element.
	 */
	public string[] attr_values;

	/**
	 * Instantiates the name and content properties.
	 */
	public XmlNode () {
		this.name = "";
		this.content = "";
		this.attr_names = {};
		this.attr_values = {};
	}

	/**
	 * Returns true if this node is the root.
	 */
	public bool is_root () {
		return this.parent == null ? true : false;
	}

	/**
	 * Returns true if this node is a leaf.
	 */
	public bool is_leaf () {
		return this.children == null ? true : false;
	}

	/**
	 * Gets the root of the tree.
	 */
	public unowned XmlNode get_root () {
		if (this.is_root ()) {
			return this;
		}
		else {
			return this.parent.get_root ();
		}
	}

	/**
	 * Looks for a node with the given name and gets it if found.
	 */
	public unowned XmlNode? get_node_by_name (string name, XmlNode? node_ref = null) {
		unowned XmlNode? wanted_node = null;

		/* 
		 * The first time get_node_by_name is called, node_ref should be null. This
		 * connects it to the root.
		 */
		if (node_ref == null) {
			node_ref = this.get_root ();
		}

		/*
		 * If this node is the one we are looking for, return it
		 */
		if (node_ref.name == name) {
			return node_ref;
		}

		/*
		 * Else, check the children nodes
		 */
		if (node_ref.children != null) {
			node_ref = node_ref.children;

			while (node_ref != null) {
				// Recursion!
				wanted_node = node_ref.get_node_by_name (name, node_ref);

				// If the wanted node was found, stop the process
				if(wanted_node != null) {
					break;
				}

				node_ref = node_ref.next;
			}

			return wanted_node;
		}

		return null;
	}

	/**
	 * Gets the last child node
	 */
	public unowned XmlNode? get_last_child () {
		if (this.children == null) {
			return null;
		}
		
		unowned XmlNode child = this.children;
 
		while (child.next != null) {
			child = child.next;
		}

		return child;
	}

	/**
	 * Adds node as last child.
	 */
	public void add_child (XmlNode node) {
		// If this node has no children, change the children reference
		if (this.children == null) {
			this.children = node;
		}
		// Else, add it after the last one
		else {
			unowned XmlNode? last_child = this.get_last_child ();

			last_child.next = node;
			node.prev = last_child;
		}

		node.parent = this;
	}
}