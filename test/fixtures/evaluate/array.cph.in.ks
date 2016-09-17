require expect: func

heroes = ['leto', 'duncan', 'goku']

evenHeroes = [hero for hero, index in heroes when index % 2 == 0]

expect(evenHeroes).to.eql(['leto', 'goku'])