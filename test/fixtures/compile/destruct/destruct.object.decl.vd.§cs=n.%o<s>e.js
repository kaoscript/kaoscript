const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let key = "qux";
	let  __ks_0 = (() => {
		const o = new OBJ();
		o.qux = "bar";
		return o;
	})();
	Helper.assertDexObject(__ks_0, 0, 0, {[key]: Type.isValue});
	let {[key]: foo} = __ks_0;
	console.log(foo);
};