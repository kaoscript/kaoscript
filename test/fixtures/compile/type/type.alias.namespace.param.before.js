const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function({match}) {
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = Foobar.Matcher.is;
		if(args.length === 1) {
			if(t0(args[0])) {
				return quxbaz.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	let Foobar = Helper.namespace(function() {
		const Matcher = Helper.alias(value => Type.isDexObject(value, 1, 0, {match: Type.isFunction}));
		function quxbaz() {
			return quxbaz.__ks_rt(this, arguments);
		};
		quxbaz.__ks_0 = function({match}) {
		};
		quxbaz.__ks_rt = function(that, args) {
			const t0 = Matcher.is;
			if(args.length === 1) {
				if(t0(args[0])) {
					return quxbaz.__ks_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		};
		return {
			Matcher
		};
	});
};