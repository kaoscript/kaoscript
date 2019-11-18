extern console

const arr = [1, '', true]

const [a, b, c]: [Number, String, Boolean] = arr

console.log(a + 1, `\(b)`, !c)