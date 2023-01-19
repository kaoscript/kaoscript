const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let key = "qux";
	let {[key]: foo} = (() => {
		const o = new OBJ();
		o.qux = "bar";
		return o;
	})();
	console.log(foo);
};