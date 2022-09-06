const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	class AbstractNode {
		constructor() {
			this.__ks_init();
			this.__ks_cons_rt.call(null, this, arguments);
		}
		__ks_init() {
		}
		__ks_cons_rt(that, args) {
			if(args.length !== 0) {
				throw Helper.badArgs();
			}
		}
	}
	class Root extends AbstractNode {
		static __ks_new_0() {
			const o = Object.create(Root.prototype);
			o.__ks_init();
			return o;
		}
		__ks_cons_rt(that, args) {
			super.__ks_cons_rt.call(null, that, args);
		}
		foobar() {
			return this.__ks_func_foobar_rt.call(null, this, this, arguments);
		}
		__ks_func_foobar_0(value) {
			return value;
		}
		__ks_func_foobar_rt(that, proto, args) {
			const t0 = Type.isString;
			if(args.length === 1) {
				if(t0(args[0])) {
					return proto.__ks_func_foobar_0.call(that, args[0]);
				}
			}
			if(super.__ks_func_foobar_rt) {
				return super.__ks_func_foobar_rt.call(null, that, AbstractNode.prototype, args);
			}
			throw Helper.badArgs();
		}
	}
	class Node extends AbstractNode {
		static __ks_new_0(...args) {
			const o = Object.create(Node.prototype);
			o.__ks_init();
			o.__ks_cons_0(...args);
			return o;
		}
		__ks_cons_0(parent) {
			this._parent = parent;
		}
		__ks_cons_rt(that, args) {
			const t0 = value => Type.isClassInstance(value, AbstractNode);
			if(args.length === 1) {
				if(t0(args[0])) {
					return Node.prototype.__ks_cons_0.call(that, args[0]);
				}
			}
			throw Helper.badArgs();
		}
		foobar() {
			return this._parent.__ks_func_foobar_rt.call(null, this._parent, this._parent, arguments);
		}
		__ks_func_foobar_0() {
			return this._parent.__ks_func_foobar_0(...arguments);
		}
		__ks_func_foobar_rt() {
			return this._parent.__ks_func_foobar_rt.apply(null, arguments);
		}
	}
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		return 42;
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	const root = Root.__ks_new_0();
	const level1 = Node.__ks_new_0(root);
	const level2 = Node.__ks_new_0(level1);
	const value = foobar.__ks_0();
	console.log(level2.foobar(value));
};