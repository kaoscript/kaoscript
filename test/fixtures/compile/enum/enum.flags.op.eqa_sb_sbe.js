const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const AnimalFlags = Helper.enum(Object, {
		None: 0n,
		HasClaws: 1n,
		CanFly: 2n,
		EatsFish: 4n,
		Endangered: 8n
	});
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(animal) {
		animal = AnimalFlags((animal | AnimalFlags.HasClaws) & ~AnimalFlags.CanFly & ~AnimalFlags.Endangered);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isEnumInstance(value, AnimalFlags);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};