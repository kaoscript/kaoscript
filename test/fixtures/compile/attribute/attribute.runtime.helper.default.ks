#![libstd(off)]

impl Object {
	static {
		delete(object: Object, property): Void {
			Helper.delete(object, property)
		}
	}
}