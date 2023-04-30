const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	const o = new OBJ();
	o.color = "red";
	console.log(Helper.toString(o.color));
};