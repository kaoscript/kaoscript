extern console

import '../export/export.throw.extern.we.default.ks'

try {
	foo()
}
on SyntaxError catch error {
	console.error(error)
}