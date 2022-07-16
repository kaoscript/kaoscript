const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let Float = Helper.namespace(function() {
		const PI = 3.14;
		const name = "john";
		return {
			PI,
			name
		};
	});
	console.log(Float.PI);
	console.log(Float.name);
};