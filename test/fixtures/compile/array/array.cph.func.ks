likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

func spicyHeroes() {
	return [hero for like, hero of likes when like == 'spice']
}