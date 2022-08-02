extern console

func min() => ['female', 24]

namespace foo {
	export var dyn [gender, age] = min()
}

console.log(foo.age)
console.log(`\(foo.gender)`)