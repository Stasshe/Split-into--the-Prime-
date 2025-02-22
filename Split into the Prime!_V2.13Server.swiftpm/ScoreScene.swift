import SpriteKit
import SwiftUI
import UIKit
var isloading = false
class ScoreScene: SKScene {
    var finalScore: Int = 0  // ゲーム終了時のスコア
    var difficulty: String = "easy" // 難易度を保持
    var highScores: [Int] = [] // ランキングスコア
    var usernames: [String] = []
    var endtime = "Limited"
    var show_rank_from_gameover = false

    
    
    override func didMove(to view: SKView) {
        backgroundColor = .white
        AudioManager.shared.playSound(fileName: "jazz") // 
        // ランキングを取得
        //highScores = loadHighScores(for: difficulty)
        
        // 難易度を表示
        if endtime == "Endless"{
            let difficultyLabel = SKLabelNode(text: "Difficulty: \(difficulty.capitalized)")
            difficultyLabel.fontSize = 50
            difficultyLabel.fontColor = .black
            difficultyLabel.position = CGPoint(x: frame.midX, y: frame.midY + 250)
            addChild(difficultyLabel)
            let scoreLabel = SKLabelNode(text: "EndlessMode: can't save the score")
            scoreLabel.fontSize = 50
            scoreLabel.fontColor = .red
            scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY)
            addChild(scoreLabel)
            
        }else{
            let difficultyLabel = SKLabelNode(text: "Difficulty: \(difficulty.capitalized)")
            difficultyLabel.fontSize = 50
            difficultyLabel.fontColor = .black
            difficultyLabel.position = CGPoint(x: frame.midX, y: frame.midY + 240)
            addChild(difficultyLabel)

            
            let announce = SKLabelNode(text: "(2秒以上経っても反映されていない場合、ここを押してください。)")
            announce.name = "announce"
            announce.fontSize = 20
            announce.fontColor = .black
            announce.position = CGPoint(x: frame.midX, y: frame.midY + 120)
            announce.fontName = "Hiragino Sans"
            addChild(announce)
            
            
            // 現在のスコアを表示
            let scoreLabel = SKLabelNode(text: show_rank_from_gameover ? "none" : "Your Score: \(finalScore)")
            scoreLabel.fontSize = 60
            scoreLabel.fontColor = .red
            scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY + 170)
            addChild(scoreLabel)
            
            // ランキングを表示
            displayHighScores()
        }
        // "Next" ボタン
        let nextButton = SKLabelNode(text: show_rank_from_gameover ? "Back to Menu" :"Next")
        nextButton.fontSize = 60
        nextButton.fontColor = .blue
        nextButton.position = CGPoint(x: frame.midX, y: frame.midY - 280)
        nextButton.name = "nextButton"
        addChild(nextButton)
    }
    
    // ランキングを取得
    /* UsefDefaultのとき使う
    func loadHighScores(for difficulty: String) -> [Int] {
        let defaults = UserDefaults.standard
        let key = "HighScores_\(difficulty)" // 難易度ごとのキー
        return defaults.array(forKey: key) as? [Int] ?? []
    }*/
    func createTouchCircle(at position: CGPoint) {
        let circle = SKShapeNode(circleOfRadius: 10) // 半径10の円
        circle.fillColor = .clear // 塗りつぶしなし
        circle.strokeColor = .black // 線の色を黒に
        circle.lineWidth = 1 // 線の太さを2に設定
        circle.position = position
        // ボールのタップ判定に影響しないように設定
        circle.zPosition = -5 // 背景レイヤーに置く
        circle.isUserInteractionEnabled = false
        addChild(circle)
        // アニメーションでフェードアウト＆拡大しながら消える
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.3)
        let group = SKAction.group([fadeOut, scaleUp])
        let remove = SKAction.removeFromParent()
        circle.run(SKAction.sequence([group, remove]))
    }
    // ランキングを表示
    func displayHighScores() {
        // ランキングタイトル
        let titleLabel = SKLabelNode(text: "Top 10 Scores")
        titleLabel.fontSize = 50
        titleLabel.fontColor = .black
        titleLabel.position = CGPoint(x: frame.midX, y: frame.midY + 300)
        addChild(titleLabel)
        
        
        // Firebase URL
        let databaseURL = "https://split-to-prime-default-rtdb.firebaseio.com/scores/\(difficulty).json"
        guard let url = URL(string: databaseURL) else { return }
        
        // データ取得
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            // レスポンスを文字列として出力（デバッグ用）
            print("Raw Response: \(String(data: data, encoding: .utf8) ?? "Invalid Data")")
            
            var highScores: [[String: Any]] = []
            
            // JSONデコード: 配列としてパース
            if let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                highScores = jsonArray
            } else {
                print("Failed to decode JSON as array")
                return
            }
            
            print("Decoded High Scores: \(highScores)")
            
            // スコアを降順でソート
            highScores.sort { (score1, score2) -> Bool in
                let score1Value = score1["score"] as? Int ?? 0
                let score2Value = score2["score"] as? Int ?? 0
                return score1Value > score2Value  // 降順
            }
            
            // メインスレッドでUI更新
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                for (index, highScore) in highScores.prefix(20).enumerated() {
                    let rank = index + 1
                    let userName = highScore["userName"] as? String ?? "Unknown"
                    let score = highScore["score"] as? Int ?? 0
                    
                    // 各要素の横の位置を決める
                    let rankX = (self?.frame.midX ?? 0) - 200 // ランクの位置
                    let nameX = (self?.frame.midX ?? 0)       // ユーザー名の位置
                    let scoreX = (self?.frame.midX ?? 0) + 200 // スコアの位置
                    let yPosition = (self?.frame.midY ?? 0) + 100 - CGFloat(rank * 30)
                    
                    // ランクラベル
                    let rankLabel = SKLabelNode(text: "\(rank) 位:")
                    rankLabel.fontName = "Hiragino Maru Gothic ProN"
                    rankLabel.fontColor = .black
                    rankLabel.horizontalAlignmentMode = .center
                    rankLabel.position = CGPoint(x: rankX, y: yPosition)
                    self?.addChild(rankLabel)
                    
                    // ユーザー名ラベル
                    let nameLabel = SKLabelNode(text: userName)
                    nameLabel.fontSize = 30
                    nameLabel.fontName = "Hiragino Maru Gothic ProN"
                    if userName == my_username {
                        nameLabel.fontColor = .green
                    }else{
                        nameLabel.fontColor = .black
                    }
                    nameLabel.horizontalAlignmentMode = .center
                    nameLabel.position = CGPoint(x: nameX, y: yPosition)
                    self?.addChild(nameLabel)
                    
                    // スコアラベル
                    let scoreLabel = SKLabelNode(text: "\(score)")
                    scoreLabel.fontSize = 30
                    scoreLabel.fontName = "Hiragino Maru Gothic ProN"
                    scoreLabel.fontColor = .black
                    scoreLabel.horizontalAlignmentMode = .center
                    scoreLabel.position = CGPoint(x: scoreX, y: yPosition)
                    self?.addChild(scoreLabel)
                    
                    
                    // ランクラベル
                    rankLabel.name = "scoreLabel"
                    // ユーザー名ラベル
                    nameLabel.name = "scoreLabel"
                    // スコアラベル
                    scoreLabel.name = "scoreLabel"
                    isloading = false

                }
                if let announce = self?.childNode(withName: "announce") as? SKLabelNode {
                    announce.text = "(2秒以上経っても反映されていない場合、ここを押してください。)"
                }

            }
        }
        task.resume()
    }

    
    // "Next"ボタンを押した際の処理
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node = atPoint(location)
            createTouchCircle(at: location)
            if node.name == "nextButton" {
                // GameOverSceneに戻る
                AudioManager.shared.playTapSound()
                let gameOverScene = GameOverScene(size: self.size)
                gameOverScene.scaleMode = .aspectFill
                view?.presentScene(gameOverScene, transition: .fade(withDuration: 1.0))
            }else if node.name == "announce"{
                if !isloading {
                    if let announce = self.childNode(withName: "announce") as? SKLabelNode {
                        announce.text = "しばらくお待ちください"
                    }
                    isloading = true
                    self.children.forEach { child in
                        if child.name == "scoreLabel" { // 名前が "scoreLabel" の場合のみ削除
                            child.removeFromParent()
                        }
                    }
                    displayHighScores()
                } 
            }
        }
    }
}

