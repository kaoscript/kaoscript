extern system class Array
extern system class String

disclose String {
	split(...): Array<String>
	replace(...): String
	trim(): String
	foobar(): Array?
}

export Array
export String