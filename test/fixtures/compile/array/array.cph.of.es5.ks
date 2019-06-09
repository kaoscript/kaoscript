#![format(functions='es5')]

likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

spicyHeroes = [hero for like, hero of likes when like == 'spice']