require|extern sealed class String {
	split(...): Array<String>
	replace(...): String
	trim(): String
}

export String

impl String {
	clean(): String => this.replace(/\s+/g, ' ').trim()
}