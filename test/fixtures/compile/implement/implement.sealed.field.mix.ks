extern sealed class Date

impl Date {
	private {
		@culture: String = 'und'
		@timezone: String
	}
	culture() => @culture
	culture(@culture) => this
	timezone() => @timezone
	timezone(@timezone) => this
}