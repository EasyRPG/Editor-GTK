/**
 * Helper class for Rect structure
 */
public class RectIterator {
	Rect rect;
	Point current;

	public RectIterator (Rect rectangle) {
		this.rect = rectangle.ex_normalize ();
		this.current = Point (rect.x-1, rect.y);

		if (rect.width == 0 || rect.height == 0) {
			current.y = rect.y+rect.height;
			current.x = rect.x+rect.width;
		}
	}

	public bool has_next () {
		if (current.y >= rect.y+rect.height-1 && current.x >= rect.x+rect.width-1)
			return false;
		return true;
	}

	public Point get () {
		return current;
	}

	public bool next () {
		if (!has_next ()) {
			return false;
		}

		current.x++;

		if (current.x >= (rect.x + rect.width)) {
			current.x = rect.x;
			current.y++;
		}

		return true;
	}
}

/**
 * A generic rect.
 */
public struct Rect {
	public int x;
	public int y;
	public int width;
	public int height;

	/**
	 * Builds the rect.
	 */
	public Rect (int x, int y, int width, int height) {
		this.set_values (x, y, width, height);
	}

	/**
	 * Sets the rect values.
	 */
	public void set_values (int x, int y, int width, int height) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	/**
	 * Normalizes the rect.
	 *
	 * This will fix a negative width or height without changing its area.
	 */
	public void normalize () {
		// If the width is negative, make it positive and recalculate x
		if (this.width < 0) {
			this.width = this.width.abs ();
			this.x = this.x - this.width + 1;
		}

		// If the height is negative, make it positive and recalculate y
		if (this.height < 0) {
			this.height = this.height.abs ();
			this.y = this.y - this.height + 1;
		}
	}

	/**
	 * FIXME
	 * This is the old normalize method. It is being used in the design tools (pen and rectangle).
	 */
	public Rect ex_normalize () {
		return Rect(
			width < 0 ? x + width : x,
			height < 0 ? y + height : y,
			width.abs (),
			height.abs ()
		);
	}

	/**
	 * Checks wether another rect overlaps this one.
	 */
	public bool overlaps (Rect rect) {
		return (
			this.x <= rect.x + rect.width - 1 &&
			this.x + this.width - 1 >= rect.x &&
			this.y <= rect.y + rect.height - 1 &&
			this.y + this.height - 1 >= rect.y
		);
	}

	/**
	 * Outputs smallest Rectangle containg this and rect
	 */
	public Rect union (Rect rect) {
		var from_x = int.min(this.x, rect.x);
		var from_y = int.min(this.y, rect.y);
		var dest_x = int.max(this.x+this.width, rect.x+rect.width);
		var dest_y = int.max(this.y+this.height, rect.y+rect.height);

		return Rect (from_x, from_y, dest_x-x, dest_y-from_y);
	}

	/**
	 * Set if the rect contains point
	 */
	public bool contains (Point p) {
		if (Utils.is_in_range (p.x, this.x, this.x+this.width-1))
			if (Utils.is_in_range (p.y, this.y, this.y+this.height-1))
				return true;

		return false;
	}

	/**
	 * Outputs the Rect's content Point by Point
	 */
	public RectIterator iterator () {
		return new RectIterator (this);
	}
}

/**
 * A generic point.
 */
public struct Point {
	public int x;
	public int y;

	/**
	 * Builds the point.
	 */
	public Point (int x, int y) {
		this.x = x;
		this.y = y;
	}
}
