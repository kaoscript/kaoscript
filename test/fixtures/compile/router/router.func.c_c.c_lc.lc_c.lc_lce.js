var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Quxbaz {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
	function foobar() {
		if(arguments.length === 2 && Type.isInstance(arguments[0], Quxbaz) && Type.isInstance(arguments[1], Quxbaz)) {
			let __ks_i = -1;
			let aType = arguments[++__ks_i];
			if(aType === void 0 || aType === null) {
				throw new TypeError("'aType' is not nullable");
			}
			else if(!Type.isInstance(aType, Quxbaz)) {
				throw new TypeError("'aType' is not of type 'Quxbaz'");
			}
			let bType = arguments[++__ks_i];
			if(bType === void 0 || bType === null) {
				throw new TypeError("'bType' is not nullable");
			}
			else if(!Type.isInstance(bType, Quxbaz)) {
				throw new TypeError("'bType' is not of type 'Quxbaz'");
			}
			return foobar([aType], [bType]);
		}
		else if(arguments.length === 2 && Type.isInstance(arguments[0], Quxbaz)) {
			let __ks_i = -1;
			let aType = arguments[++__ks_i];
			if(aType === void 0 || aType === null) {
				throw new TypeError("'aType' is not nullable");
			}
			else if(!Type.isInstance(aType, Quxbaz)) {
				throw new TypeError("'aType' is not of type 'Quxbaz'");
			}
			let bTypes = arguments[++__ks_i];
			if(bTypes === void 0 || bTypes === null) {
				throw new TypeError("'bTypes' is not nullable");
			}
			else if(!Type.isArray(bTypes, Quxbaz)) {
				throw new TypeError("'bTypes' is not of type 'Array<Quxbaz>'");
			}
			return foobar([aType], bTypes);
		}
		else if(arguments.length === 2 && Type.isInstance(arguments[1], Quxbaz)) {
			let __ks_i = -1;
			let aTypes = arguments[++__ks_i];
			if(aTypes === void 0 || aTypes === null) {
				throw new TypeError("'aTypes' is not nullable");
			}
			else if(!Type.isArray(aTypes, Quxbaz)) {
				throw new TypeError("'aTypes' is not of type 'Array<Quxbaz>'");
			}
			let bType = arguments[++__ks_i];
			if(bType === void 0 || bType === null) {
				throw new TypeError("'bType' is not nullable");
			}
			else if(!Type.isInstance(bType, Quxbaz)) {
				throw new TypeError("'bType' is not of type 'Quxbaz'");
			}
			return foobar(aTypes, [bType]);
		}
		else if(arguments.length === 2) {
			let __ks_i = -1;
			let aTypes = arguments[++__ks_i];
			if(aTypes === void 0 || aTypes === null) {
				throw new TypeError("'aTypes' is not nullable");
			}
			else if(!Type.isArray(aTypes, Quxbaz)) {
				throw new TypeError("'aTypes' is not of type 'Array<Quxbaz>'");
			}
			let bTypes = arguments[++__ks_i];
			if(bTypes === void 0 || bTypes === null) {
				throw new TypeError("'bTypes' is not nullable");
			}
			else if(!Type.isArray(bTypes, Quxbaz)) {
				throw new TypeError("'bTypes' is not of type 'Array<Quxbaz>'");
			}
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
};