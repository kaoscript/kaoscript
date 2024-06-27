#![libstd(package='.')]

syntime func print(...args) {
	quote {
		#[rules(ignore-error)]
		console.log(#(args))
	}
}

export *