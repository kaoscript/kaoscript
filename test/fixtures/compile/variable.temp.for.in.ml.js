module.exports = function() {
	function foo(x) {
		if(x === undefined || x === null) {
			throw new Error("Missing parameter 'x'");
		}
		let __ks_0 = x.foo;
		for(let __ks_1 = 0, __ks_2 = __ks_0.length, value; __ks_1 < __ks_2; ++__ks_1) {
			value = __ks_0[__ks_1];
			console.log(value);
		}
		__ks_0 = x.bar;
		for(let __ks_1 = 0, __ks_2 = __ks_0.length, value; __ks_1 < __ks_2; ++__ks_1) {
			value = __ks_0[__ks_1];
			console.log(value);
		}
	}
}