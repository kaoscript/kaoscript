#![libstd(off)]

import './generics.extern.system.default.export.ks'

impl Object {
	static {
		length(object: Object): Number => Object.keys(object).length
	}
}