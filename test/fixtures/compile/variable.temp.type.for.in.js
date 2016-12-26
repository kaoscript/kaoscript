module.exports = function() {
	var {String, __ks_String} = require("./_string")();
	function foo() {
		return ["1", "8", "F"];
	}
	let __ks_0 = foo();
	for(let __ks_1 = 0, __ks_2 = __ks_0.length, item; __ks_1 < __ks_2; ++__ks_1) {
		item = __ks_0[__ks_1];
		console.log(__ks_String._im_toInt(item, 16));
	}
}