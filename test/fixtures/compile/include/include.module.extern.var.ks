extern console

var dyn x = 42

include '@kaoscript/test-import/src/extern'

console.log(x, y, z)