extern console: {
	log(...args)
}

import * from ./import.enum.ks

console.log(Colour::Red)
console.log(Colour::DarkGreen)