import './import.req2exp1.core.ks'(require Foobar, require Quxbaz)

extern console

var f = Foobar.new()

console.log(f.x())