const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Accessibility = Helper.enum(Number, {
		Internal: 1,
		Private: 2,
		Protected: 3,
		Public: 4
	});
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(data) {
		let __ks_0;
		const access = Type.isValue(__ks_0 = Accessibility.__ks_from(data)) ? __ks_0 : Accessibility.Public;
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