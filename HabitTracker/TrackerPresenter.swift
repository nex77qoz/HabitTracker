import UIKit

protocol TrackerViewProtocol: AnyObject {
    func reloadCollectionView()
    func updatePlaceholderVisibility(isHidden: Bool)
    func reloadItems(at indexPaths: [IndexPath])
}

enum TrackerFilter: Int {
    case all         // Все трекеры
    case today       // Трекеры на сегодня
    case completed   // Завершённые
    case incomplete  // Незавершённые
}

final class TrackerPresenter: NSObject {
    weak var view: TrackerViewProtocol?
    
    private let trackerStore: TrackerStore
    private let recordStore: TrackerRecordStore
    
    private var currentDate = Date()
    private var searchText = ""
    private(set) var currentFilter: TrackerFilter = .all
    
    private var visibleCategories: [(category: TrackerCategoryCoreData, trackers: [TrackerCoreData])] = []
    
    var dailySections: [(category: TrackerCategoryCoreData, trackers: [TrackerCoreData])] {
        visibleCategories
    }
    
    init(view: TrackerViewProtocol) {
        self.view = view
        self.trackerStore = TrackerStore()
        self.recordStore = TrackerRecordStore()
        super.init()
        
        trackerStore.delegate = self
        recordStore.delegate = self
        
        applySearchFilter()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didCreateTracker(_:)),
            name: .didCreateTracker,
            object: nil
        )
    }
    
    // MARK: - Публичные методы
    
    func setFilter(_ filter: TrackerFilter) {
        if filter == .today {
            currentDate = Date()
        }
        currentFilter = filter
        applySearchFilter()
        view?.reloadCollectionView()
        updatePlaceholderVisibility()
    }
    
    func filter(with searchText: String) {
        self.searchText = searchText.lowercased()
        applySearchFilter()
        view?.reloadCollectionView()
        updatePlaceholderVisibility()
    }
    
    func datePickerValueChanged(date: Date) {
        if currentFilter == .today {
            currentFilter = .all
        }
        currentDate = date
        applySearchFilter()
        view?.reloadCollectionView()
        updatePlaceholderVisibility()
    }
    
    func updatePlaceholderVisibility() {
        let hasTrackers = !visibleCategories.isEmpty
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
    
    func deleteTracker(_ tracker: TrackerCoreData) {
        do {
            try trackerStore.deleteTracker(tracker)
        } catch {
            print("Error deleting tracker: \(error)")
        }
    }
    
    func hasAnyTrackersForSelectedDay() -> Bool {
        return !visibleCategories.isEmpty
    }
    
    // MARK: - Приватные методы
    
    private func applySearchFilter() {
        let allTrackers = trackerStore.trackers
        
        let validTrackers = allTrackers.filter { isTrackerValidForSelectedDay($0) }
        
        let searched = validTrackers.filter { tracker in
            guard let name = tracker.name else { return false }
            return searchText.isEmpty || name.lowercased().contains(searchText)
        }
        
        let groups = Dictionary(grouping: searched, by: { $0.category }).compactMap { pair -> (TrackerCategoryCoreData, [TrackerCoreData])? in
            guard let category = pair.key else { return nil }
            return (category, pair.value)
        }
        
        let sortedGroups = groups.map { (cat, trackers) -> (TrackerCategoryCoreData, [TrackerCoreData]) in
            let sortedTrackers = trackers.sorted { ($0.name ?? "") < ($1.name ?? "") }
            return (cat, sortedTrackers)
        }
        .sorted { ($0.0.title ?? "") < ($1.0.title ?? "") }
        
        visibleCategories = sortedGroups
    }
    
    private func isTrackerValidForSelectedDay(_ tracker: TrackerCoreData) -> Bool {
        if !tracker.isIrregular {
            guard
                let data = tracker.schedule as? Data,
                let schedule = try? JSONDecoder().decode(Schedule.self, from: data)
            else {
                return false
            }
            
            let systemWeekday = Calendar.current.component(.weekday, from: currentDate)
            let weekdayIndex = (systemWeekday + 5) % 7
            if !schedule.daysOfWeek[weekdayIndex] {
                return false
            }
        }
        
        switch currentFilter {
        case .all:
            return true
        case .today:
            return true
        case .completed:
            return recordFor(tracker, on: currentDate.startOfDay()) != nil
        case .incomplete:
            return recordFor(tracker, on: currentDate.startOfDay()) == nil
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
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let (_, trackers) = visibleCategories[indexPath.section]
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.identifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
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

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerPresenter: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing: CGFloat = 48
        let width = (collectionView.frame.width - totalSpacing) / 2
        return CGSize(width: width, height: 175)
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
        
        let (category, _) = visibleCategories[indexPath.section]
        header.titleLabel.text = category.title
        return header
    }
}

// MARK: - TrackerCellDelegate
extension TrackerPresenter: TrackerCellDelegate {
    func trackerCell(_ cell: TrackerCell,
                     didToggleCompletionFor tracker: TrackerCoreData,
                     at indexPath: IndexPath) {
        toggleTrackerCompletion(for: tracker, at: indexPath)
    }
}
