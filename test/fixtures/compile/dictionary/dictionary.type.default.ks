extern console

extern sealed class Dictionary

impl Dictionary {
	static size(item: Dictionary): Number => 0
}

console.log(Dictionary.size({
	name: 'White'
	honorific: 'miss'
}))