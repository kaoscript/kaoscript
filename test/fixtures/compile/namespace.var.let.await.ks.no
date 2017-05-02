extern console

func min() async => 'female'

namespace foo {
	let gender: String = await min()
}

console.log(`\(foo.gender)`)