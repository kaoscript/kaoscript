require expect: func

sealed class ClassA {
}

impl ClassA {
	foobar(...args) {
		expect(args).to.eql(['abc', 'def', 'ghi', 'jkl'])
		items.push(...args)
	}
}

const a = new ClassA()

const items = []

func foobar(values) {
	a.foobar(...values)
}

foobar(['abc', 'def', 'ghi', 'jkl'])

expect(items).to.eql(['abc', 'def', 'ghi', 'jkl'])