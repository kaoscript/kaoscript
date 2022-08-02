extern console

async func min() => 'female'

namespace foo {
	var gender = await min()
}

console.log(`\(foo.gender)`)