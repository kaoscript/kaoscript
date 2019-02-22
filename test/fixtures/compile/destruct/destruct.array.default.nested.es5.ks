#![format(destructuring='es5')]

extern console

let arr = [[1, '', true], [1, '', true]]

let [[a, b, c], [d, e, f]] = arr

console.log(a, b, c, d, e, f)