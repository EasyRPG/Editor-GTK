/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * Copyright (C) 2011 EasyRPG Project
 *
 * License: https://github.com/EasyRPG/Editor/blob/master/COPYING GPL
 *
 * Authors:
 * - Aitor García (Falc) <aitor.falc@gmail.com>
 */

/**
 * The parent class for controllers.
 */
public abstract class Controller {

	/**
	 * Every controller must have its run method, where at least one view must be instantiated.
	 */
	public abstract void run ();
}
