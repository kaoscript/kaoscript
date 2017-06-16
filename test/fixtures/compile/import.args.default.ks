extern console: {
	log(...args)
}

import './_color.default.ks'
import './_color.cie.ks'(Color, Space)

console.log(Color, Space)