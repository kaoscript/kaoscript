likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

func spicyHeroes() {
	return spicyHeroes = [hero for hero, like of likes when like == 'spice']
}