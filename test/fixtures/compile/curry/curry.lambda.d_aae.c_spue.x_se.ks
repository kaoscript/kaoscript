var f = (prefix, name) => prefix + name
var g = f^^('Hello ', ^)

echo(`\(f('Hello ', 'White'))`)
echo(`\(g('White'))`)