//
//  ViewController.swift
//  WordGarden   
//
//  Created by 최하림 on 9/12/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet weak var wordsGuessedLabel: UILabel!
    @IBOutlet weak var wordsRemainingLabel: UILabel!
    @IBOutlet weak var wordsMissedLabel: UILabel!
    @IBOutlet weak var wordsInGameLabel: UILabel!
    @IBOutlet weak var wordsBeingRevealedLabel: UILabel!
    
    @IBOutlet weak var guessedLetterTextField: UITextField!
    
    @IBOutlet weak var guessLetterButton: UIButton!
    @IBOutlet weak var playAgainButton: UIButton!
    @IBOutlet weak var gameStatusMessageLabel: UILabel!
    @IBOutlet weak var flowerImageView: UIImageView!
    
    var wordsToGuess = ["SWIFT", "DOG", "CAT"]
    var currentWordIndex = 0
    var wordToGuess = ""
    var lettersGuessed = ""
    let maxNumberOfWrongGuesses = 8
    var wrongGuessesRemaining = 8
    
    var wordsGuessedCount = 0
    var wordsMissedCount = 0
    var guessCount = 0
    var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disables "Guess a Letter" button when field is empty
        let text = guessedLetterTextField.text!
        guessLetterButton.isEnabled = !(text.isEmpty)
        wordToGuess = wordsToGuess[currentWordIndex]
        wordsBeingRevealedLabel.text = "_" + String(repeating: " _", count: wordToGuess.count-1)
        updateGameStatusLabels()
    }
    
    func formatRevealedWord() {
        // format and show revealedWord in wordBeingRevealedLabel to include new guess
        var revealedWord = ""

        // loop through all letters in wordToGuess
        for letter in wordToGuess {
            // check if letter in wordToGuess is in lettersGuessed (did you guess this letter already?)
            if lettersGuessed.contains(letter) {
                // if so, add this letter + a blank space, to revealedWord
                revealedWord = revealedWord + "\(letter) "
            } else {
                // if not, add an underscore + a blank space, to revealedWord
                revealedWord = revealedWord + "_ "
            }
        }
        // remove extra space at the end of revealedWord
        revealedWord.removeLast()
        wordsBeingRevealedLabel.text = revealedWord
    }
    
    func updateAfterWinOrLose() {
        // Game is over?
        // - increment currentWordIndex by 1
        // - disable guessALetterTextField
        // - disable guessALetterButton
        // - set playAgainButton .isHidden to false
        // - update all labels at top of screen
        
        currentWordIndex += 1
        guessedLetterTextField.isEnabled = false
        guessLetterButton.isEnabled = false
        playAgainButton.isHidden = false
        
        updateGameStatusLabels()
    }
    
    func updateGameStatusLabels() {
        // update labels at top of screen
        wordsGuessedLabel.text = "Words Guessed: \(wordsGuessedCount)"
        wordsMissedLabel.text = "Words Missed: \(wordsMissedCount)"
        wordsRemainingLabel.text = "Words to Guess: \(wordsToGuess.count - (wordsGuessedCount + wordsMissedCount))"
        wordsInGameLabel.text = "Words in Game: \(wordsToGuess.count)"
    }
    
    func drawFlowerAndPlaySound(currentLetterGuessed: String) {
        // update image, if needed, keep track of wrong guesses
        if wordToGuess.contains(currentLetterGuessed) == false {
            wrongGuessesRemaining = wrongGuessesRemaining - 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                UIView.transition(with: self.flowerImageView,
                                  duration: 0.5,
                                  options: .transitionCrossDissolve,
                                  animations: {self.flowerImageView.image = UIImage(named: "wilt\(self.wrongGuessesRemaining)")})
                { (_) in
                    
                    // if we are not on the last flower
                    // - show the next flower
                    // otherwise (we're on flower 0)
                    // - playSound("word-not-guessed")
                    // - perform another UIView.transition to flower0
                    
                    if self.wrongGuessesRemaining != 0 {
                        self.flowerImageView.image = UIImage(named: "flower\(self.wrongGuessesRemaining)")
                    } else {
                        self.playSound(name: "word-not-guessed")
                        UIView.transition(with: self.flowerImageView,
                                          duration: 0.5,
                                          options: .transitionCrossDissolve,
                                          animations: {self.flowerImageView.image = UIImage(named: "flower\(self.wrongGuessesRemaining)")},
                                          completion: nil)
                    }
                            
                }
                
                self.playSound(name: "incorrect")
            }
        } else {
            playSound(name: "correct")
        }
    }
    
    func guessALetter() {
        // Get current letter guessed, add it to all lettersGussed
        let currentLetterGuessed = guessedLetterTextField.text!
        lettersGuessed = lettersGuessed + currentLetterGuessed
        
        formatRevealedWord()

        drawFlowerAndPlaySound(currentLetterGuessed: currentLetterGuessed)
        
        // update gameStatusMessageLabel
        guessCount += 1
        let guesses = (guessCount == 1 ? "Guess" : "Guesses")
        gameStatusMessageLabel.text = "You've Made \(guessCount) \(guesses)"
        
        // Check for win or lose
        if wordsBeingRevealedLabel.text!.contains("_") == false {
            gameStatusMessageLabel.text = "You've guessed it! It took you \(guessCount) guesses to guess the word."
            wordsGuessedCount += 1
            playSound(name: "word-guessed")
            updateAfterWinOrLose()
        } else if wrongGuessesRemaining == 0 {
            gameStatusMessageLabel.text = "Sorry! You're all out of guesses."
            wordsMissedCount += 1
            updateAfterWinOrLose()
        }
        
        // check to see if all words played. if so, update message indicating player can restart the game
        if currentWordIndex == wordToGuess.count {
            gameStatusMessageLabel.text! += "\n\nYou've tried all of the words! Restart from the beginning?"
        }
    }
    
    func playSound(name: String) {
        if let sound = NSDataAsset(name: name) {
            do {
                try audioPlayer = AVAudioPlayer(data: sound.data)
                audioPlayer.play()
            } catch {
                print("🥵 ERROR: \(error.localizedDescription) Could not initialize AVAudioPlayer object")
            }
        } else {
            print("🥵 ERROR: Could not read data from file sound0")
        }
    }
    
    func updateUIAfterGuess() {
        guessedLetterTextField.resignFirstResponder()
        guessedLetterTextField.text! = ""
        guessLetterButton.isEnabled = false
    }
    
    @IBAction func guessLetterFieldChanged(_ sender: UITextField) {
        // Ensures only last character inputted by user is considered and removes whitespace (nil coalescing) + ensures uppercased letters only
        sender.text = String(sender.text!.last ?? " ").trimmingCharacters(in: .whitespaces).uppercased()
        // Disables "Guess a Letter" button when field is empty
        guessLetterButton.isEnabled = !(sender.text!.isEmpty)
    }
    
    @IBAction func doneKeyPressed(_ sender: UITextField) {
        guessALetter()
        // Dismisses the keyboard
        updateUIAfterGuess()
    }
    
    @IBAction func guessLetterButtonPressed(_ sender: UIButton) {
        guessALetter()
        // Dismisses the keyboard
        updateUIAfterGuess()
    }
    
    @IBAction func playAgainButtonPressed(_ sender: UIButton) {
        // if all words gussed and playAgain is selected, restart all games as if the app has been restarted
        if currentWordIndex == wordToGuess.count {
            currentWordIndex = 0
            wordsGuessedCount = 0
            wordsMissedCount = 0
        }
        
        playAgainButton.isHidden = true
        guessedLetterTextField.isEnabled = true
        guessLetterButton.isEnabled = false // don't turn true until a character is in text field
        wordToGuess = wordsToGuess[currentWordIndex]
        wrongGuessesRemaining = maxNumberOfWrongGuesses
        
        // create word with underscores, one for each space
        wordsBeingRevealedLabel.text = "_" + String(repeating: " _", count: wordToGuess.count-1)
        guessCount = 0
        flowerImageView.image = UIImage(named: "flower\(maxNumberOfWrongGuesses)")
        lettersGuessed = ""
        updateGameStatusLabels()
        gameStatusMessageLabel.text = "You've Made Zero Guesses"
    }
    

}

