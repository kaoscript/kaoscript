import '../_/_array'

extern sealed class Object {
	static keys(...): Array<String>
}

var mut item = {}

Object.keys(item).last()