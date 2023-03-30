const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let __ks_0;
	const foo = Helper.default((__ks_0 = (() => {
		const o = new OBJ();
		o.foo = null;
		return o;
	})()).foo, 0, () => 3), bar = __ks_0.bar, qux = Helper.default(__ks_0.qux, 1, () => 7);
	console.log(foo, bar, qux);
};