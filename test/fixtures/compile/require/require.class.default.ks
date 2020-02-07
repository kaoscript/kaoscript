require Color: class, Space: enum

impl Color {
	private _luma: Number	= 0

	luma(): Number => this._luma

	luma(@luma) => this
}

export Color, Space