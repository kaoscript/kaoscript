#![cfg(format(functions='es5'))]

likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

spicyHeroes = [hero for hero, like of likes when like == 'spice']