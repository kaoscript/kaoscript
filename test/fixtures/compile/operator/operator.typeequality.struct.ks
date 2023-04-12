struct Foobar {
}

if Foobar is Struct {
}

struct Quxbaz extends Foobar {

}

var x = Quxbaz.new()

if x is Quxbaz {

}
if x is Foobar {

}