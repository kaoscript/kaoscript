module.exports = function() {
	let Float = (function() {
		let PI = 3.14;
		let name = "john";
		return {
			PI: PI,
			name: name
		};
	})();
	console.log(Float.PI);
	console.log(Float.name);
};