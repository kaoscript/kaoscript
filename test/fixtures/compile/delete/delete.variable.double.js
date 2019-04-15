module.exports = function() {
	let foo = "bar";
	console.log(foo);
	foo = undefined;
	foo = 42;
	console.log("" + foo);
};