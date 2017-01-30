#![format(functions='es5')]

heroes = ['leto', 'duncan', 'goku']

evenHeroes = [hero for hero, index in heroes when index % 2 == 0]