#![libstd(off)]
#![runtime(prefix='KS')]

impl Object {
	static {
		delete(object: Object, property): Void {
			KSHelper.delete(object, property)
		}
	}
}