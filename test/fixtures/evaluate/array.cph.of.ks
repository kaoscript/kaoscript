require expect: func

var likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

var spicyHeroes = [hero for var like, hero of likes when like == 'spice']

expect(spicyHeroes).to.eql(['leto'])