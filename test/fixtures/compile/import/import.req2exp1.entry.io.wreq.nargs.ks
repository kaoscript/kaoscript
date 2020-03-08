import './import.req2exp1.core.ks'(require Foobar, require Quxbaz)

extern console

const f = new Foobar()

console.log(f.x())