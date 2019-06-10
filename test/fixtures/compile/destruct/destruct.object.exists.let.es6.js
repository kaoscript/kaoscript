module.exports = function() {
	const foo = {
		bar: "hello",
		baz: 3
	};
	let bar = "foo";
	let baz;
	({bar, baz} = foo);
	console.log(bar, baz);
};