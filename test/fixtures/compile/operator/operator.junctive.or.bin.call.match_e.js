const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const AnimalFlags = Helper.enum(Object, {
		None: 0n,
		HasClaws: 1n,
		CanFly: 2n,
		EatsFish: 4n,
		Endangered: 8n
	});
	function abilities() {
		return abilities.__ks_rt(this, arguments);
	};
	abilities.__ks_0 = function() {
		return AnimalFlags.None;
	};
	abilities.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return abilities.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	let __ks_0;
	if(((__ks_0 = abilities.__ks_0()) & AnimalFlags.CanFly) !== 0n || (__ks_0 & AnimalFlags.EatsFish) !== 0n) {
	}
};