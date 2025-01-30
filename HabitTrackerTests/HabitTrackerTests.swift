import XCTest
import SnapshotTesting
@testable import HabitTracker

final class TrackerViewControllerSnapshotTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        isRecording = false
    }
    
    func testTrackerViewController_Light() {
        let vc = TrackerViewController()
        
        vc.overrideUserInterfaceStyle = .light
        
        assertSnapshot(
            matching: vc,
            as: .image(on: .iPhone13Pro)
        )
    }
    
    func testTrackerViewController_Dark() {
        let vc = TrackerViewController()
        
        vc.overrideUserInterfaceStyle = .dark
        
        assertSnapshot(
            matching: vc,
            as: .image(on: .iPhone13Pro)
        )
    }
}
