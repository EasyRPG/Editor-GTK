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
	 * A reference to the parent XmlNode.
	 * 
	 * The "weak" keyword is used to avoid reference cycles.
	 * More information can be found at [[https://live.gnome.org/Vala/ReferenceHandling]]
	 */
	public weak XmlNode parent;

	/*
	 * An array containing the children XmlNodes.
	 * 
	 * It is defined as private to workaround the problem when adding items dinamically
	 * from outside the class. There are related get and set methods.
	 */
	private XmlNode[] children;

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
	}

	/**
	 * Adds a child XmlNode to the children array.
	 * 
	 * This is a workaround to the problem when adding items dinamically from outside the class.
	 */
	public void add_child (XmlNode node) {
		this.children += node;
	}

	/**
	 * Gets the length of the children array.
	 */
	public int get_children_num () {
		return this.children.length;
	}

	/*
	 * Gets an XmlNode from the children array.
	 * 
	 * @param i The position of the desired XmlNode. 
	 */
	public XmlNode get_child (int i) {
		return this.children[i];
	}
}