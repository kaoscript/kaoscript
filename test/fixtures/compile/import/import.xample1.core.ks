require|extern system class Date

disclose Date {
	getTime(): Number
}

impl Date {
	getEpochTime(): Number => this.getTime()
}

export Date