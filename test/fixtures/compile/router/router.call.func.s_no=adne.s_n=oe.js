const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function curry(kws, ...args) {
		return curry.__ks_rt(this, args, kws);
	};
	curry.__ks_0 = function(fn, bind = null) {
		return 1;
	};
	curry.__ks_rt = function(that, args, kws) {
		const t0 = Type.any;
		const t1 = Type.isString;
		if(t0(kws.bind)) {
			if(args.length === 1) {
				if(t1(args[0])) {
					return curry.__ks_0.call(that, args[0], kws.bind);
				}
			}
		}
		throw Helper.badArgs();
	};
	curry.__ks_0("", new OBJ());
};