#![format(destructuring='es5', variables='es5')]

extern console

const arr = [1, '', true]

const [a, b, c] = arr

console.log(a, b, c)