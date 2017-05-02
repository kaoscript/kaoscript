extern console

func min() async => 'female'

namespace foo {
	const gender = await min()
}

console.log(`\(foo.gender)`)