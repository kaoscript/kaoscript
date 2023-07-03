var likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

func spicyHeroes() {
	return [hero for var like, hero of likes when like == 'spice']
}