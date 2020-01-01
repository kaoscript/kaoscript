require|import './implement.systemic.constructor.clash.typing.ks'

disclose Date {
	constructor()
	constructor(date: Date)
	constructor(time: Number)
}

impl Date {
	private {
		@timezone: String	= 'Etc/UTC'
	}
	overwrite constructor(date: Date) {
		precursor(date)

		@timezone = date.timezone()
	}
	timezone(): @timezone
	timezone(@timezone): this
}