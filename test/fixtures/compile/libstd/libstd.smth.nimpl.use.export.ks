#![libstd(package='./libstd.smth.nimpl.decl.ks')]

impl Object {
	static {
		length(object: Object): Number => Object.keys(object).length
		new(): Object => {}
	}
}

export *