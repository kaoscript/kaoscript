const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Color = Helper.enum(String, {
		Red: "red",
		Green: "green",
		Blue: "blue"
	});
	const aliases = (() => {
		const d = new Dictionary();
		d.r = Color.Red;
		return d;
	})();
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		if(aliases[x] === Color.Red) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};