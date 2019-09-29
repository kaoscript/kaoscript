var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let Float = Helper.namespace(function() {
		let PI = 3.14;
		let name = "john";
		return {
			PI: PI,
			name: name
		};
	});
	console.log(Float.PI);
	console.log(Float.name);
};