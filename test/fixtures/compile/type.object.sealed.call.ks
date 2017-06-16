import './_array'

extern sealed class Object {
	static keys(...): Array<String>
}

let item := {}

Object.keys(item).last()