extern test

var dyn index = 0

echo(index)

if test {
	#[overwrite] var dyn index = index + 1

	echo(index)
}

echo(index)