module.exports = function() {
	var foo = {
		bar: "hello",
		baz: 3
	};
	var bar = foo.bar, baz = foo.baz;
	console.log(bar);
	console.log(baz);
};