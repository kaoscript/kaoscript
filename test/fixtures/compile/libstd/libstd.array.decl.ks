#![libstd(package='.')]

extern system class Array<T is Any?> {
	length: Number
	indexOf(searchElement: T, fromIndex: Number = 0): Number
	join(separator: String?): String
	map(callbackFn: Function, thisArg? = null): []
	pop(): T?
	push(...elements: T): Number
	shift(): T?
	slice(begin: Number = 0, end: Number = -1): T[]
	some(callback): Boolean
	splice(start: Number = 0, deleteCount: Number = 0, ...items: T): T[]
	sort(compare: Function? = null): T[]
	unshift(...elements: T): Number
}

export *