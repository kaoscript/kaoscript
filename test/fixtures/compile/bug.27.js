module.exports = function() {
	function corge(foo, args) {
		if(foo === undefined || foo === null) {
			throw new Error("Missing parameter 'foo'");
		}
		if(args === undefined || args === null) {
			throw new Error("Missing parameter 'args'");
		}
		let __ks_0;
		(__ks_0 = foo.bar(), __ks_0.qux).apply(__ks_0, [].concat(args));
	}
}