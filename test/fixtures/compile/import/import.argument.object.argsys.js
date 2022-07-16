const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function(__ks_String) {
	function corge() {
		return corge.__ks_rt(this, arguments);
	};
	corge.__ks_0 = function() {
		return 42;
	};
	corge.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return corge.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	function grault() {
		return grault.__ks_rt(this, arguments);
	};
	grault.__ks_0 = function(n) {
		return n + 42;
	};
	grault.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 1) {
			if(t0(args[0])) {
				return grault.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function garply() {
		return garply.__ks_rt(this, arguments);
	};
	garply.__ks_0 = function(s) {
		return s.toLowerCase();
	};
	garply.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		if(args.length === 1) {
			if(t0(args[0])) {
				return garply.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function waldo() {
		return waldo.__ks_rt(this, arguments);
	};
	waldo.__ks_0 = function() {
		return "miss White";
	};
	waldo.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return waldo.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	const foobar = (() => {
		const d = new Dictionary();
		d.corge = corge;
		d.grault = grault;
		d.garply = garply;
		d.waldo = waldo;
		return d;
	})();
	return {
		foobar
	};
};