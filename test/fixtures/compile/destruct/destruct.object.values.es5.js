var __ks__ = require("@kaoscript/runtime");
var Dictionary = __ks__.Dictionary, Helper = __ks__.Helper;
module.exports = function() {
	var __ks_0;
	var foo = Helper.default((__ks_0 = (function() {
		var d = new Dictionary();
		d.foo = 2;
		d.qux = 9;
		return d;
	})()).foo, 3), bar = Helper.default(__ks_0.bar, 6), qux = __ks_0.qux;
	console.log(foo, bar, qux);
	foo = Helper.default((__ks_0 = (function() {
		var d = new Dictionary();
		d.foo = null;
		return d;
	})()).foo, 3), bar = __ks_0.bar, qux = Helper.default(__ks_0.qux, 7);
	console.log(foo, bar, qux);
	foo = Helper.default(((function() {
		var d = new Dictionary();
		d.bar = 2;
		return d;
	})()).foo, 5);
	console.log(foo, bar, qux);
	foo = (__ks_0 = (function() {
		var d = new Dictionary();
		d.foo = 2;
		d.qux = 9;
		return d;
	})()).foo, bar = __ks_0.bar, qux = __ks_0.qux;
	console.log(foo, bar, qux);
};