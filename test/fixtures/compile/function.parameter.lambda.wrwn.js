module.exports = function() {
	let foo = function(x, y) {
		if(x === undefined) {
			throw new Error("Missing parameter 'x'");
		}
		if(y === undefined || y === null) {
			throw new Error("Missing parameter 'y'");
		}
		return [x, y];
	};
}