const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const o = (() => {
		const o = new OBJ();
		o.color = "red";
		return o;
	})();
	o.name = "White";
	console.log(o.name);
};