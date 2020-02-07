class Foobar {
	private {
		_name
		_items: Array	= []
	}
	list(fn: func) => [fn(@name, item) for item in @items]
}