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
	 * Sets the rect values.
	 */
	public void set_values (int x, int y, int width, int height) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}
}