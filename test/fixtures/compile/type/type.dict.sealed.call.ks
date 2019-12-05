import '../_/_array'

extern sealed class Object {
	static keys(...): Array<String>
}

auto item = {}

Object.keys(item).last()