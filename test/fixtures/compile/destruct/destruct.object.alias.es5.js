module.exports = function() {
	var foo = {
		bar: "hello",
		baz: 3
	};
	var a = foo.bar, b = foo.baz;
	console.log(a);
	console.log(b);
};