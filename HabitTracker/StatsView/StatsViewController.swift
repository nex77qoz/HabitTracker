import UIKit

final class StatsViewController: UIViewController, TrackerStoreDelegate, TrackerRecordStoreDelegate {
    
    private let trackerStore = TrackerStore()
    private let recordStore = TrackerRecordStore()
    
    private let placeholderStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        
        let emojiLabel = UILabel()
        emojiLabel.font = .systemFont(ofSize: 60)
        emojiLabel.text = "🥲"
        
        let textLabel = UILabel()
        textLabel.text = "Анализировать пока нечего"
        textLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        stack.addArrangedSubview(emojiLabel)
        stack.addArrangedSubview(textLabel)
        return stack
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Статистика"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        return label
    }()
    
    private let statsContainer = UIStackView()

    private let bestPeriodLabel = StatsViewController.makeStatLabel()
    private let idealDaysLabel = StatsViewController.makeStatLabel()
    private let completedTodayLabel = StatsViewController.makeStatLabel()
    private let averageValueLabel = StatsViewController.makeStatLabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .background
        trackerStore.delegate = self
        recordStore.delegate = self
        
        setupLayout()
        updateStatsUI()
    }
    
    private func setupLayout() {
        view.addSubview(titleLabel)
        [placeholderStack, statsContainer].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        statsContainer.axis = .vertical
        statsContainer.alignment = .fill
        statsContainer.spacing = 16
        
        let bestPeriodCard = makeCardView(label: bestPeriodLabel, subtitle: "Лучший период")
        let idealDaysCard = makeCardView(label: idealDaysLabel, subtitle: "Идеальные дни")
        let completedTodayCard = makeCardView(label: completedTodayLabel, subtitle: "Трекеров завершено")
        let averageValueCard = makeCardView(label: averageValueLabel, subtitle: "Среднее значение")
        
        statsContainer.addArrangedSubview(bestPeriodCard)
        statsContainer.addArrangedSubview(idealDaysCard)
        statsContainer.addArrangedSubview(completedTodayCard)
        statsContainer.addArrangedSubview(averageValueCard)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            
            placeholderStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            statsContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            statsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            statsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }
    
    private func makeCardView(label: UILabel, subtitle: String) -> UIView {
        let cardView = UIView()
        cardView.layer.cornerRadius = 8
        cardView.layer.borderWidth = 2
        cardView.layer.borderColor = UIColor.systemBlue.cgColor
        
        let vStack = UIStackView()
        vStack.axis = .vertical
        vStack.alignment = .leading
        vStack.spacing = 4
        
        let subtitleLabel = UILabel()
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.textColor = .black
        subtitleLabel.text = subtitle
        
        vStack.addArrangedSubview(label)
        vStack.addArrangedSubview(subtitleLabel)
        
        cardView.addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            vStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            vStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            vStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
        ])
        
        return cardView
    }
    
    func didUpdate() {
        updateStatsUI()
    }
    
    private func updateStatsUI() {
        let trackers = trackerStore.trackers
        if trackers.isEmpty {
            placeholderStack.isHidden = false
            statsContainer.isHidden = true
            return
        }
        
        placeholderStack.isHidden = true
        statsContainer.isHidden = false
        
        let records = recordStore.records
        
        let bestPeriod = calculateBestPeriod(records: records)
        let idealDays = calculateIdealDays(records: records, trackers: trackers)
        let completedToday = calculateCompletedToday(records: records)
        let averageValue = calculateAverageValue(records: records)
        
        bestPeriodLabel.text = "\(bestPeriod)"
        idealDaysLabel.text = "\(idealDays)"
        completedTodayLabel.text = "\(completedToday)"
        averageValueLabel.text = "\(averageValue)"
    }
    
    // MARK: - Вспомогательные методы вычисления
    
    private func calculateBestPeriod(records: [TrackerRecordCoreData]) -> Int {
        let grouped = Dictionary(grouping: records) { record -> Date in
            let day = Calendar.current.startOfDay(for: record.date ?? Date())
            return day
        }
        let maxCount = grouped.values.map { $0.count }.max() ?? 0
        return maxCount
    }
    
    private func calculateIdealDays(records: [TrackerRecordCoreData],
                                    trackers: [TrackerCoreData]) -> Int
    {
        guard !records.isEmpty else { return 0 }
        
        let dates = records.compactMap { $0.date }
        guard let minDate = dates.min(), let maxDate = dates.max() else {
            return 0
        }
        let startDay = Calendar.current.startOfDay(for: minDate)
        let endDay = Calendar.current.startOfDay(for: maxDate)
        
        var idealCount = 0
        var day = startDay
        while day <= endDay {
            let validTrackers = trackers.filter { isTrackerValid($0, for: day) }
            
            let completionsThisDay = records.filter {
                guard let recDate = $0.date else { return false }
                return Calendar.current.isDate(recDate, inSameDayAs: day)
            }
            
            if validTrackers.count > 0 &&
               completionsThisDay.count == validTrackers.count
            {
                idealCount += 1
            }
            
            day = Calendar.current.date(byAdding: .day, value: 1, to: day) ?? day
        }
        
        return idealCount
    }
    
    private func calculateCompletedToday(records: [TrackerRecordCoreData]) -> Int {
        let today = Calendar.current.startOfDay(for: Date())
        let count = records.filter {
            guard let date = $0.date else { return false }
            return Calendar.current.isDate(date, inSameDayAs: today)
        }.count
        return count
    }
    
    private func calculateAverageValue(records: [TrackerRecordCoreData]) -> Int {
        guard !records.isEmpty else { return 0 }
        
        let dates = records.compactMap { $0.date }
        guard let minDate = dates.min(), let maxDate = dates.max() else {
            return 0
        }
        
        let startDay = Calendar.current.startOfDay(for: minDate)
        let endDay = Calendar.current.startOfDay(for: maxDate)
        
        let components = Calendar.current.dateComponents([.day], from: startDay, to: endDay)
        let daysCount = (components.day ?? 0) + 1
        
        let totalCompletions = records.count
        
        let average = Double(totalCompletions) / Double(daysCount)
        return Int(average.rounded())
    }
    
    private func isTrackerValid(_ tracker: TrackerCoreData, for day: Date) -> Bool {
        if tracker.isIrregular {
            return true
        }
        
        guard
            let data = tracker.schedule as? Data,
            let schedule = try? JSONDecoder().decode(Schedule.self, from: data)
        else {
            return false
        }
        let systemWeekday = Calendar.current.component(.weekday, from: day)
        let weekdayIndex = (systemWeekday + 5) % 7
        
        return schedule.daysOfWeek[weekdayIndex]
    }
    
    static func makeStatLabel() -> UILabel {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 28, weight: .bold)
        lbl.textColor = .black
        lbl.textAlignment = .left
        lbl.text = "0"
        return lbl
    }
}
