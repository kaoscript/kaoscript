const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = (() => {
		const o = new OBJ();
		o.bar = "hello";
		o.baz = 3;
		return o;
	})();
	let {bar: a, baz: b} = foo;
	console.log(a);
	console.log(b);
};