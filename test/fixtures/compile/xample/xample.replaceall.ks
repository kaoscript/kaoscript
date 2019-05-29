extern sealed class String {
	split(): Array<String>
	replace(): String
	trim(): String
}

extern class RegExp

impl String {
	replaceAll(find: String, replacement): String {
		return this.valueOf() if find.length == 0

		if find.length <= 3 {
			return this.split(find).join(replacement)
		}
		else {
			return this.replace(new RegExp(find.escapeRegex(), 'g'), replacement)
		}
	}
}