extern console

import '../function/function.overloading.export.ks'
import '../require/require.func.default.ks'(reverse)

const foo = reverse('hello')

console.log(`\(foo)`)

export reverse