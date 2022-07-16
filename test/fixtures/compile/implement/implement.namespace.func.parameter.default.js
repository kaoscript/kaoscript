const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	let Foobar = Helper.namespace(function() {
		function foobar() {
			return foobar.__ks_rt(this, arguments);
		};
		foobar.__ks_0 = function() {
			return 42;
		};
		foobar.__ks_rt = function(that, args) {
			if(args.length === 0) {
				return foobar.__ks_0.call(that);
			}
			throw Helper.badArgs();
		};
		return {
			foobar
		};
	});
	Foobar.quxbaz = function() {
		return Foobar.quxbaz.__ks_rt(this, arguments);
	};
	Foobar.quxbaz.__ks_0 = function(foobar) {
		if(foobar === void 0 || foobar === null) {
			foobar = Foobar.foobar.__ks_0();
		}
	};
	Foobar.quxbaz.__ks_rt = function(that, args) {
		if(args.length <= 1) {
			return Foobar.quxbaz.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
};