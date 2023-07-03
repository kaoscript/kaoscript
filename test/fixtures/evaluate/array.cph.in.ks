require expect: func

var heroes = ['leto', 'duncan', 'goku']

var evenHeroes = [hero for var hero, index in heroes when index % 2 == 0]

expect(evenHeroes).to.eql(['leto', 'goku'])