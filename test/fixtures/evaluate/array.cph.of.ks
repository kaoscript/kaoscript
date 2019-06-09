require expect: func

likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

spicyHeroes = [hero for like, hero of likes when like == 'spice']

expect(spicyHeroes).to.eql(['leto'])