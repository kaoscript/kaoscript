extern console

var dyn pair = [2, -2]

match pair {
	with [x, y]	when x == y			=> console.log("These are twins")
	with [x, y]	when x + y == 0		=> console.log("Antimatter, kaboom!")
	with [x, _]	when x % 2 == 1		=> console.log("The first one is odd")
	else							=> console.log("No correlation...")
}