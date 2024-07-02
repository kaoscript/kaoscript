const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	const AnimalFlags = Helper.bitmask(Number, ["None", 0, "HasClaws", 1, "CanFly", 2, "EatsFish", 4, "Endangered", 8], ["EndangeredFlyingClawedFishEating", 15, "Predator", 3]);
	const Animal = Helper.alias((value, cast) => Type.isDexObject(value, 1, 0, {name: Type.isString, features: () => Helper.castBitmask(value, "features", AnimalFlags, cast)}));
	function restore() {
		return restore.__ks_rt(this, arguments);
	};
	restore.__ks_0 = function(animal) {
		animal = Helper.assert(animal, "\"Animal\"", 0, value => Animal.is(value, true));
	};
	restore.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return restore.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	let data = (() => {
		const o = new OBJ();
		o.name = "eagle";
		o.features = 3;
		return o;
	})();
	expect(data.features).to.equal(3);
	expect(data.features).to.not.equal(AnimalFlags.Predator);
	console.log(data);
	restore.__ks_0(data);
	console.log(data);
	expect(data.features).to.not.equal(3);
	expect(data.features).to.equal(AnimalFlags.Predator);
};