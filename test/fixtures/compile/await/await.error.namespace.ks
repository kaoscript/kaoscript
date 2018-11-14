extern console

async func min() => 'female'

namespace foo {
	const gender = await min()
}

console.log(`\(foo.gender)`)