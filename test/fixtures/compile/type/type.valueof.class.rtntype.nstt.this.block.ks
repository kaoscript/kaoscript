class Foobar {
	foobar(): valueof this {
		this.quxbaz()
	}
	quxbaz(): String => ''
}

var x = Foobar.new()

echo(`\(x.foobar().quxbaz())`)