extern console

extern sealed class Object

impl Object {
	map(iterator: func) {
		let results = []
		
		for item, index of this {
			results.push(iterator(item, index))
		}
		
		return results
	}
}

console.log({
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}.map((item, name) => {name: name, item: item}))