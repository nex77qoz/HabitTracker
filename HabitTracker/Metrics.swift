import YandexMobileMetrica

func logAndReportEvent(event: String,
                       screen: String,
                       item: String? = nil) {
    var parameters: [String: String] = [
        "event": event,
        "screen": screen
    ]
    
    if let item = item {
        parameters["item"] = item
    }
    
    print("AppMetrica event: \(parameters)")
    
    YMMYandexMetrica.reportEvent(
        "event",
        parameters: parameters
    ) { error in
        print("AppMetrica sending error: \(error.localizedDescription)")
    }
}
