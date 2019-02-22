module.exports = function() {
	const arr = [1, "", true];
	let a = "foo";
	let c = "bar";
	var [__ks_0, b, __ks_1] = arr;
	a = __ks_0;
	c = __ks_1;
	console.log(a, b, c);
};