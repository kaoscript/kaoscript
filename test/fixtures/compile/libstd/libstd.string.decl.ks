#![libstd(package='.')]

extern system class String

disclose String {
	length: Number
	charAt(index: Number): Number
	charCodeAt(index: Number): Number
	repeat(count: Number): String
	replace(pattern: RegExp | String, replacement: Function | String): String
	slice(beginIndex: Number, endIndex: Number = -1): String
	split(separator: RegExp | String | Null = null, limit: Number = -1): Array<String>
	startsWith(search: String, position: Number = 0): Boolean
	substr(start: Number, length: Number = -1): String
	substring(indexStart: Number, indexEnd: Number = -1): String
	toLowerCase(): String
	toUpperCase(): String
}

export *