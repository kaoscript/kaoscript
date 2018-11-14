extern sealed class String {
	split(...): Array<String>
}

impl String {
	capitalize(): String => this
	capitalizeWords(): String => [item.capitalize() for item in this.split(' ')].join(' ')
}