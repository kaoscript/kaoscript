extern console: {
	log(...args)
}

import '../export/export.enum.color.ks'

var dyn color = Color.Red

console.log(color)

impl Color {
	DarkRed = 3
	DarkGreen
	DarkBlue
}

color = Color.DarkGreen

console.log(color)

export Color => Colour