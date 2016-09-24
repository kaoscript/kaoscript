module.exports = function() {
	let a = "foobar";
	let arr = [1, "", true];
	var [__ks_0, b, c] = arr;
	a = __ks_0;
	console.log(a, b, c);
}