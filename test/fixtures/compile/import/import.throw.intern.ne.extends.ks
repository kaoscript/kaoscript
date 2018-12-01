extern console
extern sealed class SyntaxError

import '../export/export.throw.intern.ne.extends'

try {
	foo()
}
on SyntaxError catch error {
	console.error(error)
}