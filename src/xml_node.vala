/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * Copyright (C) 2011-2012 EasyRPG Project
 *
 * License: https://github.com/EasyRPG/Editor/blob/master/COPYING GPL
 *
 * Authors:
 * - Aitor García (Falc) <aitor.falc@gmail.com>
 * - Sebastian Reichel (sre) <sre@ring0.de>
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
	 * A hashtable containing the attributes of the element.
	 */
	public HashTable<string,string> attributes;

	/**
	 * Instantiates the name and content properties.
	 */
	public XmlNode (string name = "") {
		this.name = name;
		this.content = "";
		this.attributes = new HashTable<string,string>(str_hash, str_equal);
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
	public XmlNode get_root () {
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
	public XmlNode? get_node_by_name (string name, XmlNode? node_ref = null) {
		XmlNode? wanted_node = null;
		XmlNode? current_node = node_ref;

		/*
		 * The first time get_node_by_name is called, node_ref should be null. This
		 * connects it to the root.
		 */
		if (current_node == null) {
			current_node = this.get_root ();
		}

		/*
		 * If this node is the one we are looking for, return it
		 */
		if (current_node.name == name) {
			return current_node;
		}

		/*
		 * Else, check the children nodes
		 */
		if (current_node.children != null) {
			current_node = current_node.children;

			while (current_node != null) {
				// Recursion!
				wanted_node = current_node.get_node_by_name (name, current_node);

				// If the wanted node was found, stop the process
				if(wanted_node != null) {
					break;
				}

				current_node = current_node.next;
			}

			return wanted_node;
		}

		return null;
	}

	/**
	 * Gets the last child node
	 */
	public XmlNode? get_last_child () {
		if (this.children == null) {
			return null;
		}

		XmlNode child = this.children;

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
			XmlNode? last_child = this.get_last_child ();

			last_child.next = node;
			node.prev = last_child;
		}

		node.parent = this;
	}
}
