const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let __ks_0;
	const foo = Helper.default((__ks_0 = (() => {
		const o = new OBJ();
		o.foo = 2;
		o.qux = 9;
		return o;
	})()).foo, 1, () => 3), bar = Helper.default(__ks_0.bar, 1, () => 6), qux = __ks_0.qux;
	console.log(foo, bar, qux);
};