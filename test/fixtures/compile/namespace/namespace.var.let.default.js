const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let Float = Helper.namespace(function() {
		let PI = 3.14;
		let name = "john";
		return {
			PI,
			name
		};
	});
	console.log(Float.PI);
	console.log(Float.name);
};