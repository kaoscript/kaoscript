var {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function min() {
		return (() => {
			const d = new Dictionary();
			d.gender = "female";
			d.age = 24;
			return d;
		})();
	}
	let foo = Helper.namespace(function() {
		let {gender, age} = min();
		return {
			gender: gender,
			age: age
		};
	});
	console.log(foo.age);
	console.log(Helper.toString(foo.gender));
};