const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function color() {
		return color.__ks_rt(this, arguments);
	};
	color.__ks_0 = function() {
		return "red";
	};
	color.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return color.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	let __ks_0;
	if((__ks_0 = color.__ks_0()) === "black" || __ks_0 === "white") {
	}
};