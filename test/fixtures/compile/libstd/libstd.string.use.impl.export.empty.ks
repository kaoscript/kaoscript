#![libstd(package='./libstd.string.decl.ks')]

extern {
	func parseFloat(...): Number
	func parseInt(...): Number

	system class String {
	}
}

impl String {
	lower(): String => this.toLowerCase()
	toFloat(): Number => parseFloat(this)
	toInt(base = 10): Number => parseInt(this, base)
}

export String