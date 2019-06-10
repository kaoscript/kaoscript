module.exports = function() {
	let arr = [[1, "", true], [1, "", true]];
	let a = "foo";
	let f = "bar";
	let b, c, d, e;
	[[a, b, c], [d, e, f]] = arr;
	console.log(a, b, c, d, e, f);
};