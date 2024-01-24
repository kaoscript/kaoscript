func age(): Number => 15

func main() {
	match age() {
		0						=> echo(`I'm not born yet I guess`)
		1  .. 12 	with var n	=> echo(`I'm a child of age \(n)`)
		13 .. 19 	with var n	=> echo(`I'm a teen of age \(n)`)
					with var n	=> echo(`I'm an old person of age \(n)`)
	}
}