require expect: func

var original = { a: 1, b: 2 }

expect({ ...original, c: 3 }).to.eql({a: 1, b: 2, c: 3})