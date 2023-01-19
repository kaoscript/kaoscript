const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = (() => {
		const o = new OBJ();
		o.bar = "hello";
		o.baz = 3;
		return o;
	})();
	let {bar, baz} = foo;
	console.log(bar);
	console.log(baz);
};