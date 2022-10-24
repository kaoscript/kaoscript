type AsyncFn = (#[retain] done: Function): Void
type SyncFn = (): Void

extern {
	func it(title: String, fn: SyncFn | AsyncFn)
}

it('print', () => {
})