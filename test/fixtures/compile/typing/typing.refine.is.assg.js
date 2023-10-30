const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
		if(Type.isString(value.coord)) {
			const parts = /^(\d+);(\d+)$/.exec(value.coord);
			value.coord = (() => {
				const o = new OBJ();
				o.x = parts[1];
				o.y = parts[2];
				return o;
			})();
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};