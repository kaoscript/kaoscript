extern console

extern sealed class Object

impl Object {
	map(iterator: func) {
		var dyn results = []

		for var item, index of this {
			results.push(iterator(item, index))
		}

		return results
	}
}

console.log({
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}.map((item, name) => ({name: name, item: item})))