var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	class Type {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("wrong number of arguments");
			}
		}
		static __ks_sttc_import_0(data, references, domain, node) {
			if(arguments.length < 4) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 4)");
			}
			if(data === void 0 || data === null) {
				throw new TypeError("'data' is not nullable");
			}
			if(references === void 0 || references === null) {
				throw new TypeError("'references' is not nullable");
			}
			else if(!Type.isObject(references)) {
				throw new TypeError("'references' is not of type 'Object'");
			}
			if(domain === void 0 || domain === null) {
				throw new TypeError("'domain' is not nullable");
			}
			else if(!Type.is(domain, Domain)) {
				throw new TypeError("'domain' is not of type 'Domain'");
			}
			if(node === void 0 || node === null) {
				throw new TypeError("'node' is not nullable");
			}
			else if(!Type.is(node, AbstractNode)) {
				throw new TypeError("'node' is not of type 'AbstractNode'");
			}
			return Type.import(null, data, references, domain, node);
		}
		static __ks_sttc_import_1(name, data, references, node) {
			if(arguments.length < 4) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 4)");
			}
			if(name === void 0 || name === null) {
				throw new TypeError("'name' is not nullable");
			}
			else if(!Type.isString(name)) {
				throw new TypeError("'name' is not of type 'String'");
			}
			if(data === void 0 || data === null) {
				throw new TypeError("'data' is not nullable");
			}
			if(references === void 0 || references === null) {
				throw new TypeError("'references' is not nullable");
			}
			else if(!Type.isObject(references)) {
				throw new TypeError("'references' is not of type 'Object'");
			}
			if(node === void 0 || node === null) {
				throw new TypeError("'node' is not nullable");
			}
			else if(!Type.is(node, AbstractNode)) {
				throw new TypeError("'node' is not of type 'AbstractNode'");
			}
			return Type.import(name, data, references, node.scope().domain(), node);
		}
		static __ks_sttc_import_2(name, data, references, domain, node) {
			if(arguments.length < 5) {
				throw new SyntaxError("wrong number of arguments (" + arguments.length + " for 5)");
			}
			if(name === void 0) {
				name = null;
			}
			else if(name !== null && !Type.isString(name)) {
				throw new TypeError("'name' is not of type 'String'");
			}
			if(data === void 0 || data === null) {
				throw new TypeError("'data' is not nullable");
			}
			if(references === void 0 || references === null) {
				throw new TypeError("'references' is not nullable");
			}
			if(domain === void 0 || domain === null) {
				throw new TypeError("'domain' is not nullable");
			}
			else if(!Type.is(domain, Domain)) {
				throw new TypeError("'domain' is not of type 'Domain'");
			}
			if(node === void 0 || node === null) {
				throw new TypeError("'node' is not nullable");
			}
			else if(!Type.is(node, AbstractNode)) {
				throw new TypeError("'node' is not of type 'AbstractNode'");
			}
		}
		static import() {
			if(arguments.length === 4) {
				if(Type.is(arguments[2], Domain)) {
					return Type.__ks_sttc_import_0.apply(this, arguments);
				}
				else {
					return Type.__ks_sttc_import_1.apply(this, arguments);
				}
			}
			else if(arguments.length === 5) {
				return Type.__ks_sttc_import_2.apply(this, arguments);
			}
			throw new SyntaxError("wrong number of arguments");
		}
	}
};