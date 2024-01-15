require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var AnimalFlags = require("./.bitmask.export.default.ks.j5k8r9.ksb")().AnimalFlags;
	function printAnimalAbilities() {
		return printAnimalAbilities.__ks_rt(this, arguments);
	};
	printAnimalAbilities.__ks_0 = function(abilities) {
		if((abilities & AnimalFlags.HasClaws) == AnimalFlags.HasClaws) {
			console.log("animal has claws");
		}
		if((abilities & AnimalFlags.CanFly) == AnimalFlags.CanFly) {
			console.log("animal can fly");
		}
		if(abilities === AnimalFlags.None) {
			console.log("nothing");
		}
	};
	printAnimalAbilities.__ks_rt = function(that, args) {
		const t0 = value => Type.isBitmaskInstance(value, AnimalFlags);
		if(args.length === 1) {
			if(t0(args[0])) {
				return printAnimalAbilities.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};