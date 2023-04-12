#[rules(non-exhaustive)]
extern sealed class Array {
	join(...): String
}

#[rules(non-exhaustive)]
extern sealed class String {
	split(...): Array<String>
	replace(...): String
	trim(): String
	valueOf(): String
}

extern class RegExp

impl String {
	replaceAll(find: String, replacement): String {
		return this.valueOf() if find.length == 0

		if find.length <= 3 {
			return this.split(find).join(replacement)
		}
		else {
			return this.replace(RegExp.new(find.escapeRegex(), 'g'), replacement)
		}
	}
}