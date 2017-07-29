extern console

macro trace_build_age_with_reification() {
	const buildTime = Math.floor((new Date(2013, 2, 1)).getTime() / 1000)
	
	macro {
		const runTime = Math.floor(Date.now() / 1000)
		const age = runTime - #buildTime
		
		console.log(`Right now it's \(runTime), and this build is \(age) seconds old`)
	}
}

trace_build_age_with_reification!()