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
}
