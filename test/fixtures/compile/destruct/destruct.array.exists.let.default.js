module.exports = function() {
	const arr = [1, "", true];
	let a = "foo";
	var [__ks_0, b, c] = arr;
	a = __ks_0;
	console.log(a, b, c);
};