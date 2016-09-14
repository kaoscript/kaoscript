extern console: {
	log(...args)
}

import * from ./_color.ks
import * from ./_color.cie.ks with Color, Space

console.log(Color, Space)