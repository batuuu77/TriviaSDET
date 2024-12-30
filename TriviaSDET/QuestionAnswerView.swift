import SwiftUI

struct QuestionAnswerView: View {
    var topic: String

    var body: some View {
        Text("Questions and Answers for \(topic)")
    }
}

struct QuestionAnswerView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionAnswerView(topic: "Sample Topic")
    }
}

