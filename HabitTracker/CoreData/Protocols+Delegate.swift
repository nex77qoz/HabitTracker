protocol TrackerStoreDelegate: AnyObject {
    func didUpdate()
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func didUpdate()
}

protocol TrackerRecordStoreDelegate: AnyObject {
    func didUpdate()
}
