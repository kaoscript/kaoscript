const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let __ks_0;
	let foo = Helper.default((__ks_0 = (() => {
		const o = new OBJ();
		o.foo = 2;
		o.qux = 9;
		return o;
	})()).foo, 3), bar = Helper.default(__ks_0.bar, 6), qux = __ks_0.qux;
	console.log(foo, bar, qux);
	foo = Helper.default((__ks_0 = (() => {
		const o = new OBJ();
		o.foo = null;
		return o;
	})()).foo, 3), bar = __ks_0.bar, qux = Helper.default(__ks_0.qux, 7);
	console.log(foo, bar, qux);
	foo = Helper.default(((() => {
		const o = new OBJ();
		o.bar = 2;
		return o;
	})()).foo, 5);
	console.log(foo, bar, qux);
	({foo, bar, qux} = (() => {
		const o = new OBJ();
		o.foo = 2;
		o.qux = 9;
		return o;
	})());
	console.log(foo, bar, qux);
};