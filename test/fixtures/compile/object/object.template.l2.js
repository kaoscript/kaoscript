module.exports = function() {
	let x = "y";
	let foo = {
		bar: {}
	};
	foo.bar[x] = 42;
};