module.exports = function() {
	let foo = function() {
		if(arguments.length < 1) {
			throw new Error("Wrong number of arguments");
		}
		let __ks_i = -1;
		if(arguments.length > 1) {
			var x = arguments[++__ks_i];
		}
		else {
			var x = null;
		}
		var y = arguments[++__ks_i];
		return [x, y];
	};
}