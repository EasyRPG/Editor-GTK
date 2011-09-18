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

public class XmlNode {
	/*
	 * Properties
	 */
	public string name;
	public string content;
	public weak XmlNode parent;
	private XmlNode[] children;
	public string[] attr_names;
	public string[] attr_values;

	/*
	 * Constructor
	 */
	public XmlNode () {
		this.name = "";
		this.content = "";
	}

	/*
	 * Add children
	 * 
	 * It is not possible to add items dinamically to an array from outside the
	 * class. Workaround: make it private and use a public method.
	 */
	public void add_children (XmlNode node) {
		this.children += node;
	}

	/*
	 * Get children number
	 */
	public int get_children_num () {
		return this.children.length;
	}

	/*
	 * Get child
	 */
	public XmlNode get_child (int i) {
		return this.children[i];
	}
}