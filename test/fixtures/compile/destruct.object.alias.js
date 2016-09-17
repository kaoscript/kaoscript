module.exports = function() {
	let foo = {
		bar: "hello",
		baz: 3
	};
	var {bar: a, baz: b} = foo;
	console.log(a);
	console.log(b);
}