require expect: func

sealed class ClassA {
}

impl ClassA {
	foobar(...args) {
		expect(args).to.eql(['abc', 'def', 'ghi', 'jkl'])
		items.push(...args)
	}
}

var a = new ClassA()

var items = []

func foobar(values: Array) {
	a.foobar(...values)
}

foobar(['abc', 'def', 'ghi', 'jkl'])

expect(items).to.eql(['abc', 'def', 'ghi', 'jkl'])