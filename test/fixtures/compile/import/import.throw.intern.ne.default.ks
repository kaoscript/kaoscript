extern console

import '../export/export.throw.intern.ne.default'

try {
	foo()
}
on Error catch error {
	console.error(error)
}