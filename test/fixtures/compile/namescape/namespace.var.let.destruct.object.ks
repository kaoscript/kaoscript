extern console

func min() => {
	gender: 'female'
	age: 24
}

namespace foo {
	export let {gender, age} = min()
}

console.log(foo.age)
console.log(`\(foo.gender)`)