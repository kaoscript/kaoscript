export class URI {
	macro register(@scheme: String, @meta: String = 'hier_part [ "?" query ] [ "#" fragment ]') {
		import '@kaoscript/test-import/src/index'

		const name = `\(scheme[0].toUpperCase())\(scheme.substr(1).toLowerCase())URI`

		macro {
			class #i(name) extends URI {
				private {
					_e: Number	= #PI
				}
			}
		}
	}
}

URI.register!('file', '[ "//" [ host ] ] path_absolute')