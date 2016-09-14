require Color: class, Space: enum

impl Color {
	private _luma: Number
	
	luma() -> Number => this._luma
	
	luma(@luma: Number) => this
}

export Color, Space