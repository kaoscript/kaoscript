extern console

import '../function/function.overloading.export.ks'

func reverse(value: Number): Number => -value

const foo = reverse('hello')

console.log(`\(foo)`)

export reverse