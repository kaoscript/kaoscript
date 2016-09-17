require expect: func

likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

spicyHeroes = [hero for hero, like of likes when like == 'spice']

expect(spicyHeroes).to.eql(['leto'])