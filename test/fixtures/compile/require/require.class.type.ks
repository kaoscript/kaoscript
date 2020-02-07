require {
	enum Space<String> {
		RGB
	}

	class Color {
		space(): Space
		space(space: Space): Color
	}
}

impl Color {
	private _luma: Number	 = 0

	luma(): Number => this._luma

	luma(@luma) => this
}

export Color, Space