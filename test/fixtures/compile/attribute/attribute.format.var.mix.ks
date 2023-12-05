#![format(variables='es6')]

extern test

var dyn x = 0
echo(x)

if test {
	var dyn x = 42
	echo(x)
}

echo(x)

#[format(variables='es5')]
if test {
	var dyn x = 24
	echo(x)
}

echo(x)

if test {
	var dyn x = 10
	echo(x)
}

echo(x)