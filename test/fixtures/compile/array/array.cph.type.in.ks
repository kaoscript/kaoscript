var heroes = ['leto', 'duncan', 'goku']

var flag = false

export var evenHeroes = flag ? [hero for hero, index in heroes when index % 2 == 0] : []