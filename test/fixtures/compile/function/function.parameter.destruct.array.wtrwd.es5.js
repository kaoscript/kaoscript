module.exports = function() {
	function foobar(__ks_0) {
		if(__ks_0 === void 0 || __ks_0 === null) {
			__ks_0 = ["foo", "bar"];
		}
		var x = __ks_0[0], y = __ks_0[1];
		console.log(x + "." + y);
	}
};