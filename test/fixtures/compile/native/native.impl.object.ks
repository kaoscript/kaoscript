extern console

extern sealed class Dictionary

impl Dictionary {
	map(iterator: func) {
		var dyn results = []

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
}.map((item, name) => ({name: name, item: item})))