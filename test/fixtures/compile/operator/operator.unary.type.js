const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let x = "john";
	console.log(Helper.toString(Type.isValue(x.toUpperCase)));
};