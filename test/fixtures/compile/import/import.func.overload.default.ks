extern console

import '../function/function.overloading.export.ks'

func reverse(value: Number): Number => -value

var foo = reverse('hello')

console.log(`\(foo)`)

export reverse