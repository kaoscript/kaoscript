require sealed class Color

impl Color {
	private {
		@luma: Number
	}
	luma(): @luma
	luma(@luma): this
}

export Color