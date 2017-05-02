module.exports = function() {
	function min() {
		return ["female", 24];
	}
	let foo = (function() {
		var [gender, age] = min();
		return {
			gender: gender,
			age: age
		};
	})();
	console.log(foo.age);
	console.log("" + foo.gender);
}