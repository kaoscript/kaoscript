extern console

syntime func trace_build_age_with_reification() {
	var dyn d = Date.new(2013, 2, 15)

	d.setUTCDate(1)
	d.setUTCHours(0, 0, 0)

	var buildTime = Math.floor(d.getTime()!? / 1000)

	quote {
		var runTime = Math.floor(Date.now()!? / 1000)
		var age = runTime - #(buildTime)

		console.log(`Right now it's \(runTime), and this build is \(age) seconds old`)
	}
}

trace_build_age_with_reification()