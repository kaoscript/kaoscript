const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Color = Helper.enum(String, 0, "Red", "red", "Green", "green", "Blue", "blue");
	function toColor() {
		return toColor.__ks_rt(this, arguments);
	};
	toColor.__ks_0 = function(value) {
		const color = Color("red");
		return color;
	};
	toColor.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return toColor.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};