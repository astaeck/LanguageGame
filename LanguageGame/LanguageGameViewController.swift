//
//  LanguageGameViewController.swift
//  LanguageGame
//
//  Created by Angelina Staeck on 07.05.18.
//  Copyright © 2018 Angelina Staeck. All rights reserved.
//

import UIKit

class LanguageGameViewController: UIViewController {
    @IBOutlet var wordToTranslate: UILabel!
    @IBOutlet var animatingTranslation: UILabel!
    @IBOutlet var centerYConstraint: NSLayoutConstraint!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var gradientView: UIView!
    @IBOutlet var rejectButton: UIButton!
    @IBOutlet var roundLabel: UILabel!
    @IBOutlet var scoreLabel: UILabel!
    @IBOutlet var rightOrWrongIndicator: UILabel!
    private var gradient: CAGradientLayer!
    var animator = UIViewPropertyAnimator()

    lazy var viewModel: LanguageGameViewModel = {
        return LanguageGameViewModel()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        setupLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.startGameCallback = { [weak self] wordPair in
            guard let wordToTranslate = wordPair?.englishText else { return }
            self?.wordToTranslate.text = wordToTranslate
            self?.startAnimation()
        }
        viewModel.updateRound = { [weak self] round in
            self?.roundLabel.text = "\(round) | 3"
        }
        viewModel.updateScore = { [weak self] score, answerIndicator in
            self?.rightOrWrongIndicator.text = answerIndicator
            self?.scoreLabel.text = "\(score) | 9"
        }
        viewModel.gameFinished = { [weak self] score in
            self?.showAlert(withScore: score)
        }
       
        viewModel.readWordPairsFromFile()
    }
    
    func showAlert(withScore score: Int) {
        let alertVC = UIAlertController(title: "Game is finished", message: "You had \(score) correct answers", preferredStyle: .alert)
        let playAction = UIAlertAction(title: "Play again", style: .default) { action in
            self.animator.stopAnimation(true)
            self.centerYConstraint.constant = 0
            self.view.layoutIfNeeded()
            self.viewModel.resetGame()
        }
        alertVC.addAction(playAction)
        self.present(alertVC, animated: true)
    }
    
    func startAnimation() {
        guard let translation = self.viewModel.getRandomTranslation() else { return }
        self.animatingTranslation.text = translation
        self.view.layoutIfNeeded()

        animator = UIViewPropertyAnimator(duration: 8, curve: .linear, animations: {
            self.centerYConstraint.constant = self.view.bounds.height + 100
            self.view.layoutIfNeeded()
        })
        animator.addCompletion { position in
            self.viewModel.removeRandomTranslation(translation: self.animatingTranslation.text ?? "")
            self.rightOrWrongIndicator.text = ""
            self.centerYConstraint.constant = 0
            self.view.layoutIfNeeded()
            self.viewModel.checkRound()
        }
        animator.startAnimation()
    }
    
    @IBAction func pressedAnswerButton(_ sender: UIButton) {
        self.animator.stopAnimation(true)
        self.centerYConstraint.constant = 0
        self.view.layoutIfNeeded()
        self.viewModel.removeRandomTranslation(translation: self.animatingTranslation.text ?? "")

        switch sender.tag {
        case 1:
            viewModel.checkAnswer(isCorrect: true, text: animatingTranslation.text ?? "")
        case 2:
            viewModel.checkAnswer(isCorrect: false, text: animatingTranslation.text ?? "")

        default:
            break
        }
    }
    
    func setupLayout() {
        gradient = CAGradientLayer()
        gradient.frame = gradientView.bounds
        gradient.colors = [UIColor.white.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.white.cgColor]
        gradient.locations = [0, 0.3, 0.7, 1]
        gradientView.layer.mask = gradient
        submitButton.layer.cornerRadius = 5
        rejectButton.layer.cornerRadius = 5
        submitButton.tag = 1
        rejectButton.tag = 2
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradient.frame = gradientView.bounds
    }
}
