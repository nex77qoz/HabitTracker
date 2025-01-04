// TrackerPresenter.swift

import UIKit

protocol TrackerViewProtocol: AnyObject {
    func reloadCollectionView()
    func updatePlaceholderVisibility(isHidden: Bool)
    func reloadItems(at indexPaths: [IndexPath])
}

final class TrackerPresenter: NSObject {
    weak var view: TrackerViewProtocol?
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore
    private var currentDate = Date()
    
    private var dailySections: [(category: TrackerCategoryCoreData, trackers: [TrackerCoreData])] {
        let all = trackerStore.trackers
        let valid = all.filter { isTrackerValidForToday($0) }
        
        let groups = Dictionary(grouping: valid, by: { $0.category }).compactMap { pair -> (TrackerCategoryCoreData, [TrackerCoreData])? in
            guard let category = pair.key else { return nil }
            return (category, pair.value)
        }
        
        let sortedGroups = groups.map { (cat, trackers) -> (TrackerCategoryCoreData, [TrackerCoreData]) in
            let sortedTrackers = trackers.sorted { ($0.name ?? "") < ($1.name ?? "") }
            return (cat, sortedTrackers)
        }
        .sorted { ($0.0.title ?? "") < ($1.0.title ?? "") }
        
        return sortedGroups
    }
    
    init(view: TrackerViewProtocol) {
        self.view = view
        self.trackerStore = TrackerStore()
        self.recordStore = TrackerRecordStore()
        super.init()
        trackerStore.delegate = self
        recordStore.delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didCreateTracker(_:)),
            name: .didCreateTracker,
            object: nil
        )
    }
    
    func datePickerValueChanged(date: Date) {
        currentDate = date
        view?.reloadCollectionView()
        updatePlaceholderVisibility()
    }
    
    func updatePlaceholderVisibility() {
        let hasTrackers = !dailySections.isEmpty
        view?.updatePlaceholderVisibility(isHidden: hasTrackers)
    }
    
    func toggleTrackerCompletion(for tracker: TrackerCoreData, at indexPath: IndexPath) {
        let day = currentDate.startOfDay()
        
        if let record = recordFor(tracker, on: day) {
            try? recordStore.deleteRecord(record)
        } else {
            let newRecord = TrackerRecord(trackerId: tracker.id ?? UUID(), date: day)
            try? recordStore.addRecord(newRecord, tracker: tracker)
        }
        
        view?.reloadItems(at: [indexPath])
    }
    
    @objc private func didCreateTracker(_ notification: Notification) {
        guard
            let newTracker = notification.object as? Tracker,
            let categoryCoreData = notification.userInfo?["category"] as? TrackerCategoryCoreData
        else {
            return
        }
        do {
            try trackerStore.addTracker(newTracker, category: categoryCoreData)
        } catch {
            print("Error creating tracker: \(error)")
        }
    }
    
    private func isTrackerValidForToday(_ t: TrackerCoreData) -> Bool {
        if t.isIrregular {
            return true
        } else {
            guard
                let data = t.schedule as? Data,
                let schedule = try? JSONDecoder().decode(Schedule.self, from: data)
            else {
                return false
            }
            let weekdayIndex = Calendar.current.component(.weekday, from: currentDate) - 1
            return schedule.daysOfWeek[weekdayIndex]
        }
    }
    
    private func recordFor(_ tracker: TrackerCoreData, on date: Date) -> TrackerRecordCoreData? {
        recordStore.records.first {
            $0.trackerId == tracker.id &&
            ($0.date.map { Calendar.current.isDate($0, inSameDayAs: date) } ?? false)
        }
    }
    
    private func totalDaysCompleted(_ tracker: TrackerCoreData) -> Int {
        recordStore.records.filter { $0.trackerId == tracker.id }.count
    }
}

// MARK: - Store Delegates
extension TrackerPresenter: TrackerStoreDelegate, TrackerRecordStoreDelegate {
    func didUpdate() {
        view?.reloadCollectionView()
        updatePlaceholderVisibility()
    }
}

// MARK: - UICollectionView DataSource
extension TrackerPresenter: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        dailySections.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        dailySections[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.identifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let (category, trackers) = dailySections[indexPath.section]
        let tracker = trackers[indexPath.item]
        let day = currentDate.startOfDay()
        let isCompleted = (recordFor(tracker, on: day) != nil)
        let daysCount = totalDaysCompleted(tracker)
        let isFutureDate = (day > Date().startOfDay())
        
        cell.configure(
            with: tracker,
            completed: isCompleted,
            daysCount: daysCount,
            isFutureDate: isFutureDate
        )
        cell.delegate = self
        cell.indexPath = indexPath
        
        return cell
    }
}

// MARK: - UICollectionView Delegate Flow Layout
extension TrackerPresenter: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing: CGFloat = 48
        let width = (collectionView.frame.width - totalSpacing) / 2
        return CGSize(width: width, height: 175)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 50)
    }
}

// MARK: - Header View
extension TrackerPresenter {
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard
            kind == UICollectionView.elementKindSectionHeader,
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerHeaderView.identifier,
                for: indexPath
            ) as? TrackerHeaderView
        else {
            return UICollectionReusableView()
        }
        
        let (category, _) = dailySections[indexPath.section]
        header.titleLabel.text = category.title
        return header
    }
}

// MARK: - TrackerCell Delegate
extension TrackerPresenter: TrackerCellDelegate {
    func trackerCell(_ cell: TrackerCell,
                     didToggleCompletionFor tracker: TrackerCoreData,
                     at indexPath: IndexPath) {
        toggleTrackerCompletion(for: tracker, at: indexPath)
    }
}
