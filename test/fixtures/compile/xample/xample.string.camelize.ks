require|extern systemic class String

disclose String {
	length: Number
	replace(pattern: RegExp | String, replacement: Function | String): String
	toLowerCase(): String
	toUpperCase(): String
}

impl String {
	camelize(): String => this.replace(/[-_\s]+(.)/g, (m, l) => l.toUpperCase())
}