extern console: {
	log(...args)
}

import Color as C, Space as S from ./_color.ks
console.log(C, S)

import Color as C, Space as S from ./_color.cie.ks with C as Color, S as Space
console.log(C, S)