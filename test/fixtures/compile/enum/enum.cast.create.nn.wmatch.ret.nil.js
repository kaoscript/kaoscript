const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Color = Helper.enum(String, {
		Red: "red",
		Green: "green",
		Blue: "blue"
	});
	function color() {
		return color.__ks_rt(this, arguments);
	};
	color.__ks_0 = function(value) {
		return Color.__ks_from("red");
	};
	color.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return color.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};