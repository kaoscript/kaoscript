extern sealed class Array
extern sealed class String

disclose String {
	split(...): Array<String>
	replace(...): String
	trim(): String
	foobar(): Array?
}

export Array
export String