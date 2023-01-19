const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = (() => {
		const o = new OBJ();
		o.bar = (() => {
			const o = new OBJ();
			o.n1 = "hello";
			o.n2 = "world";
			return o;
		})();
		return o;
	})();
	let {bar: {n1, n2: qux}} = foo;
	console.log(n1, qux);
};