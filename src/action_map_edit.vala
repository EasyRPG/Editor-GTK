/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * action_map_edit.vala
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

namespace UndoManager {
	/**
	 * The parent class for Actions used by the History for undo/redo.
	 */
	public class MapEditAction : UndoManager.Action {
		private int[,] diff;
		private LayerType layer;

		/**
		 * Creates a new MapEditAction
		 * 
		 * @param layer The layer being changed
		 * @param diff The changes applied to layer
		 * @param changes The number of tiles being changed, use 0 to auto-detect
		 */
		public MapEditAction (LayerType layer, int[,] diff, int changes=0) {
			this.diff  = diff;
			this.layer = layer;

			stdout.printf ("action changed: %d/%d\n", changes, diff.length[0] * diff.length[1]);

			/* TODO: compress diff depending on the number of changed tiles:
				if big change:
					integer stream, use negative numbers for sequences of 0, e.g. -2 = 0,0,0
				if small change:
					hashmap<Point,int>
			*/
		}

		/**
		 * Applies the EditAction to Map
		 * 
		 * @param map The map object being changed
		 */
		public override void apply (Map map) {
			unowned int[,] layer;

			switch (this.layer) {
				case LayerType.LOWER:
					layer = map.lower_layer;
					break;
				case LayerType.UPPER:
					layer = map.upper_layer;
					break;
				default:
					warning ("unsupported MapEditAction!");
					return;
			}

			for (int y = 0; y < layer.length[0]; y++)
				for (int x = 0; x < layer.length[1]; x++)
					layer[y,x] -= diff[y,x];
		}

		/**
		 * revert an apply ();
		 * 
		 * @param map The map object being changed
		 */
		public override void unapply (Map map) {
			unowned int[,] layer;

			switch (this.layer) {
				case LayerType.LOWER:
					layer = map.lower_layer;
					break;
				case LayerType.UPPER:
					layer = map.upper_layer;
					break;
				default:
					warning ("unsupported MapEditAction!");
					return;
			}

			for (int y = 0; y < layer.length[0]; y++)
				for (int x = 0; x < layer.length[1]; x++)
					layer[y,x] += diff[y,x];
		}
	}
}
