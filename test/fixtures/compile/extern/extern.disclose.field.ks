#![libstd(off)]

extern system class String

disclose String {
	length: Number
	split(...): Array<String>
	replace(...): String
	trim(): String
}

export String