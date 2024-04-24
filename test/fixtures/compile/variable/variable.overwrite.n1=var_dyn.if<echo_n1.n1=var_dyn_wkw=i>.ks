extern test

var dyn index = 0

echo(index)

if test {
	echo(index)

	#[overwrite] var dyn index = 42

	echo(index)
}

echo(index)