import './implement.rtntype.method.instance.gss.ks'

extern console

impl Foobar {
	value(): @value
	value(@value): this
}

var f = Foobar.new()

console.log(`\(f.value('foobar').value())`)

export Foobar