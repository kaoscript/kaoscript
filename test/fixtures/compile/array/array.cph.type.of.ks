const likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

const flag = false

export const spicyHeroes = flag ? [hero for hero, like of likes when like == 'spice'] : []