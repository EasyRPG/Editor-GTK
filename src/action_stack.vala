/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * action_stack.vala
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
 * The History for undo/redo operations.
 */
public class ActionStack {
	private Queue<Action> actions;
	private Map map;

	/**
	 * Points to the last applied Action
	 */
	private int current;

	/**
	 * Send if undo availability changes
	 */
	public signal void can_undo_changed ();

	/**
	 * Send if redo availability changes
	 */
	public signal void can_redo_changed ();

	/**
	 * ActionStack providing Undo/Redo abilities.
	 */
	public ActionStack (Map map) {
		this.actions = new Queue<Action> ();
		this.current = -1;
		this.map = map;
	}

	/**
	 * Clears the whole ActionStack.
	 */
	public void clear () {
		actions.clear ();
		current = -1;
	}

	/**
	 * Push a Action on the ActionStack.
	 */
	public void push (Action action) {
		bool redo_changed = current < (((int) actions.length)-1);

		/* drop all Actions, which are currently unapplied */
		while (current < (((int) actions.length)-1))
			actions.pop_tail ();

		/* append action */
		actions.push_tail (action);

		current++;

		/* update redo/undo state */
		if (redo_changed)
			can_redo_changed ();

		if (current == 0)
			can_undo_changed ();
	}

	/**
	 * Perform a single undo.
	 */
	public void undo () {
		if (current < 0)
			return;

		current--;
		actions.peek_nth (current+1).unapply (map);

		/* is undo unavailable now? */
		if (current < 0)
			can_undo_changed ();

		/* was redo unavailable before? */
		if (current == actions.length-2)
			can_redo_changed ();
	}

	/**
	 * Perform a single redo.
	 */
	public void redo () {
		if (current >= (((int) actions.length)-1))
			return;

		current++;
		actions.peek_nth (current).apply (map);

		/* is redo unavailable now? */
		if (current >= actions.length-1)
			can_redo_changed ();

		/* was undo unavailable before? */
		if (current == 0)
			can_undo_changed ();
	}

	/**
	 * Get whether there are redo operations available.
	 */
	public bool can_redo () {
		return (current < (((int) actions.length)-1));
	}

	/**
	 * Get whether there are undo operations available.
	 */
	public bool can_undo () {
		return (current > -1);
	}
}
