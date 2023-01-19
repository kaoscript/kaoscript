const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	let foo = (() => {
		const o = new OBJ();
		o.bar = "qux";
		return o;
	})();
	delete foo.bar;
};