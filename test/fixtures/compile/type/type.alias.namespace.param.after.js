const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let Foobar = Helper.namespace(function() {
		const __ksType0 = {
			isMatcher: value => Type.isDexObject(value, 1, 0, {match: Type.isFunction})
		};
		function quxbaz() {
			return quxbaz.__ks_rt(this, arguments);
		};
		quxbaz.__ks_0 = function({match}) {
		};
		quxbaz.__ks_rt = function(that, args) {
			const t0 = __ksType0.isMatcher;
			if(args.length === 1) {
				if(t0(args[0])) {
					return quxbaz.__ks_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		};
		return {
			__ksType: [__ksType0.isMatcher]
		};
	});
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function({match}) {
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = Foobar.__ksType[0];
		if(args.length === 1) {
			if(t0(args[0])) {
				return quxbaz.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};