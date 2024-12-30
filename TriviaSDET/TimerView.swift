import SwiftUI

struct TimerView: View {
    let startTime: Date
    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Text(timeString)
            .font(.system(.subheadline, design: .monospaced))
            .foregroundColor(.white.opacity(0.7))
            .onReceive(timer) { _ in
                currentTime = Date()
            }
    }
    
    private var timeString: String {
        let interval = currentTime.timeIntervalSince(startTime)
        return interval.formatDuration()
    }
}
