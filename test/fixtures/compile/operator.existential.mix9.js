var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	let __ks_0, __ks_1;
	if(Type.isFunction(foo) && Type.isFunction((__ks_0 = foo(), __ks_0.bar)) && Type.isFunction(foo) && Type.isFunction((__ks_1 = foo(), __ks_1.qux)) ? __ks_0.bar() > __ks_1.qux() : false) {
		console.log(foo);
	}
	if(Type.isFunction(foo) && Type.isFunction((__ks_0 = foo(), __ks_0.bar)) && Type.isFunction(foo) && Type.isFunction((__ks_1 = foo(), __ks_1.qux)) ? __ks_0.bar() > __ks_1.qux() : false) {
		console.log(foo);
	}
}