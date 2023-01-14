extern console: {
	log(...args)
}

func age(): Number => 15

func main() {
	match age() {
		0					=> console.log(`I'm not born yet I guess`)
		1  .. 12 	with n	=> console.log(`I'm a child of age \(n)`)
		13 .. 19 	with n	=> console.log(`I'm a teen of age \(n)`)
					with n	=> console.log(`I'm an old person of age \(n)`)
	}
}