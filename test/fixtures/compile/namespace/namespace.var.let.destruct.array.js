var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	function min() {
		return ["female", 24];
	}
	let foo = Helper.namespace(function() {
		let [gender, age] = min();
		return {
			gender: gender,
			age: age
		};
	});
	console.log(foo.age);
	console.log(Helper.toString(foo.gender));
};