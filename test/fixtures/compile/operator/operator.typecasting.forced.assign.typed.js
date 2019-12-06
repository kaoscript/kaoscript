module.exports = function() {
	function foobar() {
		let values = null;
		values = quxbaz();
		for(let __ks_0 = 0, __ks_1 = values.length, value; __ks_0 < __ks_1; ++__ks_0) {
			value = values[__ks_0];
			console.log(value);
		}
	}
	function quxbaz() {
		return "foobar";
	}
};