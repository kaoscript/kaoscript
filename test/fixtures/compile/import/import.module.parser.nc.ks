extern sealed class SyntaxError

import '@kaoscript/parser' for parse

try {
	const ast = parse('const foo = 42')
}