const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const ANSIColor = Helper.enum(Number, 0, "BLACK", 0, "RED", 1, "GREEN", 2, "YELLOW", 3, "BLUE", 4, "MAGENTA", 5, "CYAN", 6, "WHITE", 7, "DEFAULT", 8);
	function print() {
		return print.__ks_rt(this, arguments);
	};
	print.__ks_0 = function(color) {
		if(color === ANSIColor.BLACK) {
			console.log("black");
		}
	};
	print.__ks_rt = function(that, args) {
		const t0 = value => Type.isEnumInstance(value, ANSIColor);
		if(args.length === 1) {
			if(t0(args[0])) {
				return print.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};