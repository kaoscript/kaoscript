require expect: func

a = [i for i in 0..10]

expect(a).to.eql([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10])