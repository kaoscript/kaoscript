class Foobar {
	private {
		@parent: Foobar?
		@type: String?
	}
	constructor(@parent, @type = parent?.type())
	type(): @type
}