const likes = {
	leto: 'spice'
	paul: 'chani'
	duncan: 'murbella'
}

const flag = false

export const spicyHeroes = flag ? [hero for like, hero of likes when like == 'spice'] : []