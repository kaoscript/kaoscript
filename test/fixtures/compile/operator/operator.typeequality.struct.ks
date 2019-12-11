struct Foobar {
}

if Foobar is Struct {
}

struct Quxbaz extends Foobar {

}

const x = Quxbaz()

if x is Quxbaz {

}
if x is Foobar {

}