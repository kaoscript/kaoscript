extern console

extern sealed class Object

impl Object {
	static size(item: Object): Number => 0
}

console.log(Object.size({
	name: 'White'
	honorific: 'miss'
}))