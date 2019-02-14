extern console: {
	log(...args)
}

import '../export/export.enum.color.ks'

let color = Color::Red

console.log(color)

enum Color {
	DarkRed = 3
	DarkGreen
	DarkBlue
}

color = Color::DarkGreen

console.log(color)

export Color => Colour