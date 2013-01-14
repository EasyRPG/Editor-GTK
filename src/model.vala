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
 * The parent class for models.
 */
public abstract class Model {

	/**
	 * Every model must have its load data method, with a XmlNode data parameter.
	 * 
	 * @param data An XmlNode that represents some XML data. 
	 */
	public abstract void load_data (XmlNode? data);

	/**
	 * Every model must have its save data method, with a XmlNode data parameter.
	 *
	 * @param data An XmlNode that represents some XML data.
	 */
	public abstract void save_data (out XmlNode data);
}
