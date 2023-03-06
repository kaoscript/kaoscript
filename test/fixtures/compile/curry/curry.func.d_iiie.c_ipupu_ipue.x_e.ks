func add(x: Number, y: Number, z: Number) => x + y + z

var addOne = add^^(1, ^, ^)

var addTwo = addOne^^(2, ^)

echo(addTwo())