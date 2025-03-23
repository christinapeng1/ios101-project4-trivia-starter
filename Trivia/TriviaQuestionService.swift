//
//  TriviaQuestionService.swift
//  Trivia
//
//  Created by Christina Peng on 3/22/25.
//

import Foundation

class TriviaQuestionService {
    static func fetchQuestion(amount: Int,
                              difficulty: String,
                              completion: (([TriviaQuestion]) -> Void)? = nil) {
        let parameters = "amount=\(amount)&difficulty=\(difficulty)&type=multiple"
        let url = URL(string: "https://opentdb.com/api.php?\(parameters)")!
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // this closure is fired when the response is received
            guard error == nil else {
                assertionFailure("Error: \(error!.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                assertionFailure("Invalid response")
                return
            }
            guard let data = data, httpResponse.statusCode == 200 else {
                assertionFailure("Invalid response status code: \(httpResponse.statusCode)")
                return
            }
            let questions = parse(data: data)
            DispatchQueue.main.async {
                completion?(questions) // call the completion closure and pass in the forecast data model
            }
            // at this point, `data` contains the data received from the response
        }
        task.resume() // resume the task and fire the request
    }
    private static func parse(data: Data) -> [TriviaQuestion] {
        let jsonDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        guard let results = jsonDictionary["results"] as? [[String: Any]] else {
                fatalError("Failed to parse results from JSON")
            }
        var questions: [TriviaQuestion] = []
        for item in results {
                if let category = item["category"] as? String,
                   let question = item["question"] as? String,
                   let correctAnswer = item["correct_answer"] as? String,
                   let incorrectAnswers = item["incorrect_answers"] as? [String] {
                    
                    let triviaQuestion = TriviaQuestion(
                        category: category,
                        question: question,
                        correctAnswer: correctAnswer,
                        incorrectAnswers: incorrectAnswers
                    )
                    questions.append(triviaQuestion)
                }
            }

            return questions
      }
}
