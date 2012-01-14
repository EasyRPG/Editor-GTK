/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * action.vala
 * Copyright (C) EasyRPG Project 2012
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
 * The parent class for Actions used by the History for undo/redo.
 */
public abstract class Action {

	/**
	 * Every action must have an apply method
	 * 
	 * @param map The map object being changed
	 */
	public abstract void apply (Map map);

	/**
	 * Every action must have an unapply method
	 * 
	 * @param map The map object being changed
	 */
	public abstract void unapply (Map map);
}
