/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * Copyright (C) 2012 EasyRPG Project
 *
 * License: https://github.com/EasyRPG/Editor/blob/master/COPYING GPL
 *
 * Authors:
 * - Sebastian Reichel (sre) <sre@ring0.de>
 */

namespace UndoManager {
	/**
	 * The History for undo/redo operations.
	 */
	public class Stack {
		private Queue<UndoManager.Action> actions;
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
		public Stack (Map map) {
			this.actions = new Queue<UndoManager.Action> ();
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
		public void push (UndoManager.Action action) {
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
}
