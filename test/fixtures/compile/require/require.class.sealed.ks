require sealed class Color

impl Color {
	private {
		@luma: Number	= 0
	}
	luma(): @luma
	luma(@luma): this
}

export Color