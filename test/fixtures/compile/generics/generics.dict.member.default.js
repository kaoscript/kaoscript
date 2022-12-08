const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const map = (() => {
		const d = new OBJ();
		d.pi = 3.14;
		return d;
	})();
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	foobar.__ks_0(map.pi + 1);
};