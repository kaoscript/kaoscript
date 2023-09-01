extern foo, bar

var dyn tt = foo()

tt ?? (tt <- bar())