func foobar(x! = 'foobar') {
}

class Master {
	foobar(x! = 'foobar') {
	}
}

var m = Master.new()

m.foobar(null)