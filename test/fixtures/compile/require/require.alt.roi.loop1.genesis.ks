require|extern system class Array
require|extern system class Object

impl Array {
	static clone(value: Array): Array => this
}

impl Object {
	static clone(value: Object): Object => this
}

func clone(value: Array): Array => this
func clone(value: Object): Object => this
func clone(value?) => value

export Array, Object, clone