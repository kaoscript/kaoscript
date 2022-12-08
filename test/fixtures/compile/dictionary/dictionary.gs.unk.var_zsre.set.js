const {OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const o = (() => {
		const d = new OBJ();
		d.color = "red";
		return d;
	})();
	o.name = "White";
	console.log(o.name);
};