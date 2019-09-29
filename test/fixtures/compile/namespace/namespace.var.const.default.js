var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	let Float = Helper.namespace(function() {
		const PI = 3.14;
		const name = "john";
		return {
			PI: PI,
			name: name
		};
	});
	console.log(Float.PI);
	console.log(Float.name);
};