#![format(variables='es6')]

extern test

var dyn x = 0
echo(x)

var dyn o = {}
o.x = 30

if test {
	var dyn x = 42
	echo(x)

	if test {
		var dyn x = 10
		echo(x)
	}

	echo(x)
}

echo(x)

func foo() {
	var dyn x = 5
}