const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = (() => {
		const d = new OBJ();
		d.bar = "hello";
		d.baz = 3;
		return d;
	})();
	let {bar: a, baz: b} = foo;
	console.log(a);
	console.log(b);
};