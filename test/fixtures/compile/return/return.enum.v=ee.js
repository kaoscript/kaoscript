const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const Color = Helper.enum(String, {
		Red: "red",
		Green: "green",
		Blue: "blue"
	});
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		return Color.Red.value;
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};