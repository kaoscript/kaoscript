const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y, z, foo, bar, qux) {
		if(x === true) {
			if(foo === true) {
			}
			else if(bar === true) {
			}
			else if(qux === true) {
			}
			else {
			}
		}
		else if(y === true) {
		}
		else if(z === true) {
			if(foo === true) {
			}
			else if(bar === true) {
			}
			else if(qux === true) {
			}
			else {
			}
		}
		else {
			if(foo === true) {
			}
			else if(bar === true) {
			}
			else if(qux === true) {
			}
			else {
			}
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 6) {
			if(t0(args[0]) && t0(args[1]) && t0(args[2]) && t0(args[3]) && t0(args[4]) && t0(args[5])) {
				return foobar.__ks_0.call(that, args[0], args[1], args[2], args[3], args[4], args[5]);
			}
		}
		throw Helper.badArgs();
	};
};