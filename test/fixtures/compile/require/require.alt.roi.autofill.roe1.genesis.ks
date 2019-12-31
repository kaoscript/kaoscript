require|extern systemic class Array
require|extern systemic class String
require class Foobar

disclose Array {
	length: Number
	concat(...values): Array
	every(callback: Function, thisArg: Dictionary = null): Boolean
	forEach(callback: Function, thisArg: Dictionary = null): void
	indexOf(searchElement, fromIndex: Number = 0): Number
	join(separator: String = ','): String
	pop(): Any
	push(...elements): Number
	shift(): Any
	slice(begin: Number = 0, end: Number = -1)
	some(callback: Function, thisArg: Dictionary = null): Boolean
	sort(compare: Function = null): Array
	splice(start: Number, delete: Number = -1, ...items): Array
	toString(): String
	unshift(...elements): Number
}

disclose String {
	length: Number
	charAt(index: Number): String
	charCodeAt(index: Number): Number
	concat(...strings: Array<String>): String
	fromCharCode(...numbers: Array<Number>): String
	indexOf(search: String, fromIndex: Number = 0): Number
	lastIndexOf(search: String, fromIndex: Number = 0): Number
	match(regexp: RegExp): Array<String>?
	replace(pattern: RegExp | String, replacement: Function | String): String
	search(regexp: RegExp): Number
	slice(beginIndex: Number, endIndex: Number = -1): String
	split(separator: RegExp | String = null, limit: Number = -1): Array<String>
	substr(start: Number, length: Number = -1): String
	substring(indexStart: Number, indexEnd: Number = -1): String
	toLowerCase(): String
	toString(): String
	toUpperCase(): String
	trim(): String
	valueOf(): String
}

impl Array {
	last(index: Number = 1) {
		return this.length != 0 ? this[this.length - index] : null
	}
}

impl String {
	lines(emptyLines: Boolean = false): Array<String> {
		if this.length == 0 {
			return []
		}
		else if emptyLines {
			return this.replace(/\r\n/g, '\n').replace(/\r/g, '\n').split('\n')
		}
		else {
			return this.match(/[^\r\n]+/g) ?? []
		}
	}
}

export Array, String