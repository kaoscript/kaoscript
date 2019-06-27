extern console

let pair = [2, -2]

switch pair {
	with [x, y]	where x == y		=> console.log("These are twins")
	with [x, y]	where x + y == 0	=> console.log("Antimatter, kaboom!")
	with [x,]	where x % 2 == 1	=> console.log("The first one is odd")
									=> console.log("No correlation...")
}