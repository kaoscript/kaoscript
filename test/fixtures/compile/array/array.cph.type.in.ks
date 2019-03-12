const heroes = ['leto', 'duncan', 'goku']

const flag = false

export const evenHeroes = flag ? [hero for hero, index in heroes when index % 2 == 0] : []