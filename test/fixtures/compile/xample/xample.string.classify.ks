extern system class String {
	replace(...): String
}

impl String {
	capitalizeWords(): String => this
	classify(): String => this.replace(/[-_]/g, ' ').replace(/([A-Z])/g, ' $1').capitalizeWords().replace(/\s/g, '')
}

export String