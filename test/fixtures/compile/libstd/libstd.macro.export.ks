#![libstd(package='.')]

macro print(...args) {
	macro {
		#[rules(ignore-error)]
		console.log(#(args))
	}
}

export *