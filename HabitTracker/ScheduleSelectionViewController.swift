//
//  ScheduleSelectionViewController.swift
import UIKit

final class ScheduleSelectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: ScheduleSelectionDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let doneButton = UIButton.roundedButton(
        title: "Готово",
        backgroundColor: .black,
        titleColor: .white,
        selector: #selector(doneButtonTapped),
        target: self
    )
    
    private let days = [
        "Понедельник", "Вторник", "Среда",
        "Четверг", "Пятница", "Суббота",
        "Воскресенье"
    ]
    
    var selectedDays: Set<String> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DayCell")
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -16),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 60
        tableView.separatorInset = .zero
    }
    
    @objc private func doneButtonTapped() {
        delegate?.scheduleSelected(selectedDays)
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITableViewDataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DayCell", for: indexPath)
        let dayName = days[indexPath.row]
        
        cell.textLabel?.text = dayName
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
        
        let switchView = UISwitch()
        switchView.onTintColor = .systemBlue
        switchView.isOn = selectedDays.contains(dayNameShort(dayName))
        switchView.tag = indexPath.row
        switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
        cell.accessoryView = switchView
        
        cell.selectionStyle = .none
        return cell
    }
    
    private func dayNameShort(_ fullName: String) -> String {
        switch fullName {
        case "Понедельник": return "Пн"
        case "Вторник": return "Вт"
        case "Среда": return "Ср"
        case "Четверг": return "Чт"
        case "Пятница": return "Пт"
        case "Суббота": return "Сб"
        case "Воскресенье": return "Вс"
        default: return fullName
        }
    }
    
    @objc private func switchChanged(_ sender: UISwitch) {
        let fullDayName = days[sender.tag]
        let shortName = dayNameShort(fullDayName)
        
        if sender.isOn {
            selectedDays.insert(shortName)
        } else {
            selectedDays.remove(shortName)
        }
    }
}
