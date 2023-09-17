require("kaoscript/register");
module.exports = function() {
	var {CarFactory, Car: OldCar} = require("./.typing.scope.source.ks.j5k8r9.ksb")();
	const factory = CarFactory.__ks_new_0();
	console.log(factory.__ks_func_makeCar_0().__ks_func_getType_0());
	console.log(OldCar.__ks_new_0().__ks_func_getType_0());
};