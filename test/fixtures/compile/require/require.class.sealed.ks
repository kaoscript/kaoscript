require sealed class Color

impl Color {
	private {
		@luma: Number	= 0
	}
	luma(): valueof @luma
	luma(@luma): valueof this
}

export Color