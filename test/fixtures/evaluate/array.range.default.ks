require expect: func

let a = [1..5]
expect(a).to.eql([1, 2, 3, 4, 5])

let b = [1..<5]
expect(b).to.eql([1, 2, 3, 4])

let c = [1<..5]
expect(c).to.eql([2, 3, 4, 5])

let d = [1<..<5]
expect(d).to.eql([2, 3, 4])

let e = [1..6..2]
expect(e).to.eql([1, 3, 5])

let f = [1<..<6..2]
expect(f).to.eql([3, 5])

let g = [5..1]
expect(g).to.eql([5, 4, 3, 2, 1])

let h = [5..1..2]
expect(h).to.eql([5, 3, 1])

let i = [1..3.14..0.5]
expect(i).to.eql([1.0, 1.5, 2, 2.5, 3])