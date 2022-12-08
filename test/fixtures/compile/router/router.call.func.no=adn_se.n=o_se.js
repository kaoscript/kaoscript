const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function curry(kws, ...args) {
		return curry.__ks_rt(this, args, kws);
	};
	curry.__ks_0 = function(bind = null, fn) {
	};
	curry.__ks_rt = function(that, args, kws) {
		const t0 = () => true;
		const t1 = Type.isString;
		if(t0(kws.bind)) {
			if(args.length === 1) {
				if(t1(args[0])) {
					return curry.__ks_0.call(that, kws.bind, args[0]);
				}
			}
		}
		throw Helper.badArgs();
	};
	curry.__ks_0(new OBJ(), "");
};