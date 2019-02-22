module.exports = function() {
	let arr = [[1, "", true], [1, "", true]];
	let a = "foo";
	let f = "bar";
	var [[__ks_0, b, c], [d, e, __ks_1]] = arr;
	a = __ks_0;
	f = __ks_1;
	console.log(a, b, c, d, e, f);
};