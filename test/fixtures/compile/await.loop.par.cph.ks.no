func foo(values) async => baz(await* [bar(value) for value in values])

func bar(value) async => value

func baz(values) => values