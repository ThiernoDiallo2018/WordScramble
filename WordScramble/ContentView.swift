//
//  ContentView.swift
//  WordScramble
//
//  Created by Thierno Diallo on 12/10/24.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var score = 0
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack {
                        TextField("Enter your word", text: $newWord)
                            .textInputAutocapitalization(.never)
            
                    }
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord) //can be placed anywhere and can only accept functions that do not have parameters and returns nothing.
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                // Button("Refresh", action: startGame)
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: startGame) {
                        Image(systemName: "arrow.trianglehead.2.counterclockwise.rotate.90")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Text("Score: \(score)")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
            }
        }
       
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        //the guard is checking to make sure its correct. It will only
        
        guard answer.count > 0 else { return }
        
        guard answer.count >= 3 else {
            wordError(title: "Word too Short", message: "Word Must be at least 3 letters long")
            return
        }
        //answer does not equal to root word
        guard answer != rootWord else {
            wordError(title: "Incorrect", message: "Answer cannot equal to Root Word")
            return
        }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        withAnimation {
            usedWords.insert(answer, at: 0) //can use append but then we would change the order of the list
        } //Cool animation!!
        
        newWord = ""
        score += answer.count
    }
    
    func startGame() {
        //Checking for our file and pulling out the data and connecting it to rootWord
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "Silkworm"
                return //everythign worked
            }
        }
        fatalError( "Couldn't find start words file") //everything failed
    }
    
    //Check whether the word has been used before or not
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    //Checking if the word inputted can be made from the rootword
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    //Making the sure the word is real
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
        
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
