const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let __ks_0;
	let foo = Helper.default((__ks_0 = (() => {
		const d = new OBJ();
		d.foo = 2;
		d.qux = 9;
		return d;
	})()).foo, 3), bar = Helper.default(__ks_0.bar, 6), qux = __ks_0.qux;
	console.log(foo, bar, qux);
	foo = Helper.default((__ks_0 = (() => {
		const d = new OBJ();
		d.foo = null;
		return d;
	})()).foo, 3), bar = __ks_0.bar, qux = Helper.default(__ks_0.qux, 7);
	console.log(foo, bar, qux);
	foo = Helper.default(((() => {
		const d = new OBJ();
		d.bar = 2;
		return d;
	})()).foo, 5);
	console.log(foo, bar, qux);
	({foo, bar, qux} = (() => {
		const d = new OBJ();
		d.foo = 2;
		d.qux = 9;
		return d;
	})());
	console.log(foo, bar, qux);
};