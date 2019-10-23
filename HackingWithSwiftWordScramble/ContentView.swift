//
//  ContentView.swift
//  HackingWithSwiftWordScramble
//
//  Created by Matthew Ginelli on 10/21/19.
//  Copyright © 2019 MGinelli. All rights reserved.
//

import SwiftUI




struct ContentView: View {
    @State private var providedWord = ""
    @State private var newWord = ""
    @State private var createdWords = [String]()
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var wordCount = 0
    @State private var numberOfPossibleWords = 0
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func addNewWord() {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let response = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // exit if the remaining string is empty
        guard response.count > 0 else {
            return
        }
        
        guard wordIsNotAlreadyUsed(word: response) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard wordIsPossibleFromProvidedWord(word: response) else {
            wordError(title: "Word not recognized", message: "Must contain letters from the provided word")
            return
        }
        
        guard wordExistsInDictionary(word: response) else {
            wordError(title: "Word not possible", message: "That isn't a real word.")
            return
        }
        
        guard wordIsNotTheProvidedWord(word: response) else {
            wordError(title: "Original word used", message: "You cannot use the same word provided")
            return
        }
        
        createdWords.insert(response, at: 0)
        newWord = ""
        wordCount += 1
    }
    
    func startGame(){
        createdWords = [String]()
        wordCount = 0
        // try to get the dictionary text url
        if let dictionaryURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // if you get the dictionary text, create a string of it
            if let contentsOfDictionary = try? String(contentsOf: dictionaryURL) {
                // if you get the string, then separate the words out by line breaks
                let allWords = contentsOfDictionary.components(separatedBy: "\n")
                
                // randomly choose a new word from the array. Use baseball as a default if you cant
                providedWord = allWords.randomElement() ?? "baseball"
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    func wordIsNotAlreadyUsed(word: String) -> Bool {
        !createdWords.contains(word) // check if the created words array contains the word
    }
    
    
    // ensure that the word typed is not the provided word
    func wordIsNotTheProvidedWord(word: String) -> Bool {
        if providedWord == word {
            return false
        } else {
            return true
        }
    }
    
    func wordIsPossibleFromProvidedWord(word: String) -> Bool {
        var tempWord = providedWord // create a copy of the provided word you can modify
        
        // removes the first instance of the letter if that letter is in the word
        // if all letters are removed returns true -- the word is possible from provided
        // returns false if the letter is not included in the provided word
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    
    func wordExistsInDictionary(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    
    var body: some View {
        NavigationView {
            VStack {
                Text(providedWord)
                    .font(.largeTitle)
                    .foregroundColor(.red)
                TextField("Enter your word:", text: $newWord, onCommit: addNewWord)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .autocapitalization(.none)
                Form{
                    Section(header: Text("Your words:")
                        .font(.headline)
                        .fontWeight(.bold))
                    {
                        List(createdWords, id: \.self) {
                            Text("\($0)")
                            Spacer()
                            Image(systemName: "\($0.count).circle")
                                .foregroundColor($0.count == 8 ? .green: .primary)
                        }
                    }
                }.alert(isPresented: $showingError) {
                    Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
//                Text("Number of possible words: \(numberOfPossibleWords)")
                Text("Found Word Count: \(wordCount)")
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("WordScramble")
            .navigationBarItems(trailing: Button("New Word") {self.startGame()})
            .onAppear(perform: startGame)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
