const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const o = (() => {
		const o = new OBJ();
		o.name = "White";
		return o;
	})();
	o.root = o;
	console.log(o.root.name);
};