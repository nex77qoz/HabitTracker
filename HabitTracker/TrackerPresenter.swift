import UIKit

protocol TrackerViewProtocol: AnyObject {
    func reloadCollectionView()
    func updatePlaceholderVisibility(isHidden: Bool)
    func reloadItems(at indexPaths: [IndexPath])
}

class TrackerPresenter: NSObject {
    
    weak var view: TrackerViewProtocol?
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var currentDate: Date = Date()
    
    init(view: TrackerViewProtocol) {
        self.view = view
        super.init()
        setupData()
    }
    
    func viewDidLoad() {
        updatePlaceholderVisibility()
    }
    
    private func setupData() {
        categories = [
            TrackerCategory(title: "Домашний уют", trackers: [
                Tracker(id: UUID(), name: "Поливать растения", color: "Color selection 1", emoji: "🪴",
                        schedule: Schedule(daysOfWeek: [true, false, true, false, true, false, true]))
            ]),
            TrackerCategory(title: "Здоровье", trackers: [
                Tracker(id: UUID(), name: "Сделал зарядку", color: "Color selection 2", emoji: "💪",
                        schedule: Schedule(daysOfWeek: [true, true, true, true, true, false, true])),
                Tracker(id: UUID(), name: "Не ел сладкого", color: "Color selection 3", emoji: "🍫",
                        schedule: Schedule(daysOfWeek: [true, true, true, true, true, false, false])),
                Tracker(id: UUID(), name: "Сходил на работу пешком", color: "Color selection 4", emoji: "🦶",
                        schedule: Schedule(daysOfWeek: [true, true, true, true, true, false, false]))
            ])
        ]
    }
    
    private var currentWeekday: Int {
        Calendar.current.component(.weekday, from: currentDate) - 1
    }
    
    private var filteredCategories: [TrackerCategory] {
        categories.filter { category in
            category.trackers.contains { $0.schedule.daysOfWeek[currentWeekday] }
        }
    }
    
    func datePickerValueChanged(date: Date) {
        self.currentDate = date
        view?.reloadCollectionView()
        updatePlaceholderVisibility()
    }
    
    func updatePlaceholderVisibility() {
        let trackersForCurrentDay = filteredCategories.flatMap { category in
            category.trackers.filter { $0.schedule.daysOfWeek[currentWeekday] }
        }
        
        let hasTrackersForCurrentDay = !trackersForCurrentDay.isEmpty
        view?.updatePlaceholderVisibility(isHidden: hasTrackersForCurrentDay)
    }
}

// MARK: - UICollectionView DataSource & Delegate

extension TrackerPresenter: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, TrackerCellDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let weekday = currentWeekday
        return filteredCategories[section].trackers.filter { $0.schedule.daysOfWeek[weekday] }.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        
        let weekday = currentWeekday
        let filteredTrackers = filteredCategories[indexPath.section].trackers.filter { $0.schedule.daysOfWeek[weekday] }
        let tracker = filteredTrackers[indexPath.item]
        
        let selectedDate = currentDate.startOfDay()
        let isCompleted = completedTrackers.contains { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }
        let daysCount = completedTrackers.filter { $0.trackerId == tracker.id }.count
        let isFutureDate = selectedDate > Date().startOfDay()
        
        cell.configure(with: tracker, completed: isCompleted, daysCount: daysCount, isFutureDate: isFutureDate)
        cell.delegate = self
        cell.indexPath = indexPath
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                               withReuseIdentifier: TrackerHeaderView.identifier,
                                                                               for: indexPath) as? TrackerHeaderView else {
            return UICollectionReusableView()
        }
        headerView.titleLabel.text = filteredCategories[indexPath.section].title
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalSpacing: CGFloat = 48
        let width = (collectionView.frame.width - totalSpacing) / 2
        return CGSize(width: width, height: 175)
    }
    
    // MARK: - TrackerCellDelegate
    
    func trackerCell(_ cell: TrackerCell, didToggleCompletionFor tracker: Tracker, at indexPath: IndexPath) {
        let selectedDate = currentDate.startOfDay()
        
        if let existingRecordIndex = completedTrackers.firstIndex(where: { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: selectedDate) }) {
            completedTrackers.remove(at: existingRecordIndex)
        } else {
            let newRecord = TrackerRecord(trackerId: tracker.id, date: selectedDate)
            completedTrackers.append(newRecord)
        }
        
        view?.reloadItems(at: [indexPath])
    }
}
