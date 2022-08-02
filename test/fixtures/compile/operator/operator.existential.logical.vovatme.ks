extern foo, bar, qux

var dyn tt = foo || (bar && qux?.qux)
