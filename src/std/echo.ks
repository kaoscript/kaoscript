macro echo(...args) {
	macro {
		#[rules(ignore-error)]
		console.log(#(args))
	}
}

export echo
