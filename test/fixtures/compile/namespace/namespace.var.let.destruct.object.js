var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	function min() {
		return {
			gender: "female",
			age: 24
		};
	}
	let foo = Helper.namespace(function() {
		let {gender, age} = min();
		return {
			gender: gender,
			age: age
		};
	});
	console.log(foo.age);
	console.log("" + foo.gender);
};