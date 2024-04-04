module.exports = function() {
	class Quxbaz extends Foobar {
		constructor(x, y) {
			if(y === void 0) {
				y = null;
			}
			super();
			this.constructor.prototype.__ks_init();
			this._x = x;
			this._y = y;
		}
		__ks_init() {
		}
	}
	class Corge extends Quxbaz {
		constructor(x, y) {
			if(x === void 0 || x === null) {
				x = 0;
			}
			super(x, y);
		}
		__ks_init() {
			Quxbaz.prototype.__ks_init.call(this);
		}
	}
};