#![libstd(off)]

import '../_/_array.ks'

extern sealed class Object {
	static keys(...): Array<String>
}

var mut item = {}

Object.keys(item).last()