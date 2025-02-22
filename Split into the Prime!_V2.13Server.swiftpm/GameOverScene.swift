import SpriteKit

class GameOverScene: SKScene {
    var show_rank_level = ""
    var difficulty: Difficulty {
        get {
            if let savedValue = UserDefaults.standard.value(forKey: "difficulty") as? Int,
               let savedDifficulty = Difficulty(rawValue: savedValue) {
                return savedDifficulty
            }
            return .easy // デフォルト値
        }
        set {UserDefaults.standard.set(newValue.rawValue, forKey: "difficulty")}
    }
    var currentFont: String {
        get {UserDefaults.standard.string(forKey: "currentFont") ?? "HelveticaNeue-UltraLight"}
        set {UserDefaults.standard.set(newValue, forKey: "currentFont")}
    }
    var currentShape: String {
        get {UserDefaults.standard.string(forKey: "currentShape") ?? "Cube"}
        set {UserDefaults.standard.set(newValue, forKey: "currentShape")}
    }
    var endtime: String {
        get {UserDefaults.standard.string(forKey: "endtime") ?? "Limited"}
        set {UserDefaults.standard.set(newValue, forKey: "endtime")}
    }
    var currentNight: String {
        get {UserDefaults.standard.string(forKey: "currentNight") ?? "White"}
        set {UserDefaults.standard.set(newValue, forKey: "currentNight")}
    }
    private var previous_end_config = "Limited"
    private var isSpecial = false

    override func didMove(to view: SKView) {
        backgroundColor = .white
        AudioManager.shared.playSound(fileName: "style")
        // "Try Again" ラベル
        let tryAgainLabel = SKLabelNode(text: "Try Again")
        tryAgainLabel.fontSize = 120
        tryAgainLabel.fontColor = .black
        tryAgainLabel.position = CGPoint(x: frame.midX, y: frame.midY + 130)
        tryAgainLabel.name = "restartButton"
        addChild(tryAgainLabel)
        
        // ↪︎ ボタン
        let restartButton = SKLabelNode(text: "↪︎")
        restartButton.fontSize = 120
        //restartButton.strokeColor = .white
        restartButton.fontColor = .blue
        restartButton.position = CGPoint(x: frame.midX, y: frame.midY - 10)
        restartButton.name = "restartButton"
        addChild(restartButton)
        
        
        // 難易度ラベル
        let difficultyLabel = SKLabelNode(text: "Level: \(difficultyText())")
        difficultyLabel.fontSize = 80
        //difficultyLabel.fontName = "HelveticaNeue-UltraLight"
        difficultyLabel.fontColor = .gray
        difficultyLabel.position = CGPoint(x: frame.midX, y: frame.midY-110)
        difficultyLabel.name = "difficultyLabel"
        addChild(difficultyLabel)
        
        let muteLabel = SKLabelNode(text: AudioManager.shared.isAudioMuted() ? "Mute" : "Unmute")
        muteLabel.fontSize = 60
        muteLabel.fontColor = .gray
        muteLabel.position = CGPoint(x: frame.midX-310, y: frame.midY - 230)
        muteLabel.name = "muteButton"
        addChild(muteLabel)
        
        // "Rules" ボタン 
        let rulesButton = SKLabelNode(text: "About") 
        rulesButton.fontSize = 60 
        rulesButton.fontColor = .gray 
        rulesButton.position = CGPoint(x: frame.midX-70, y: frame.midY - 230) 
        rulesButton.name = "rulesButton"
        addChild(rulesButton)
        
         
        let welcome = SKLabelNode(text: "おかえりなさい、\(my_username)さん") 
        welcome.fontSize = 20
        welcome.fontName = "Hiragino Sans"
        welcome.horizontalAlignmentMode = .left
        welcome.fontColor = .gray 
        welcome.position = CGPoint(x: frame.minX+20, y: frame.maxY - 50) 
        welcome.name = "welcome"
        addChild(welcome)
        
        let ranking = SKLabelNode(text: "今選択しているランキングを見る") 
        ranking.fontSize = 20
        ranking.fontName = "Hiragino Sans"
        ranking.horizontalAlignmentMode = .right
        ranking.fontColor = .gray 
        ranking.position = CGPoint(x: frame.maxX-20, y: frame.maxY - 50) 
        ranking.name = "ranking"
        addChild(ranking)
        
        
        var font_text = ""

        if currentFont == "HelveticaNeue-UltraLight" {font_text = "Light"}else{currentFont="TimesNewRomanPS-BoldMT";font_text = "Bold"}
        let fontChangeButton = SKLabelNode(text: "\(font_text)")
        fontChangeButton.fontSize = 60
        fontChangeButton.fontColor = .gray
        fontChangeButton.fontName = currentFont
        fontChangeButton.position = CGPoint(x: frame.midX+140, y: frame.midY - 230)
        fontChangeButton.name = "fontChangeButton" // タッチで識別できるよう名前を付ける
        addChild(fontChangeButton)
        
        let shapeChangeButton = SKLabelNode(text: "\(currentShape)")
        shapeChangeButton.fontSize = 60
        shapeChangeButton.fontColor = .gray
        shapeChangeButton.position = CGPoint(x: frame.midX+330, y: frame.midY - 230)
        shapeChangeButton.name = "shapeChangeButton" // タッチで識別できるよう名前を付ける
        addChild(shapeChangeButton)
        
        let endtimeButton = SKLabelNode(text: "Mode: \(endtime)")
        endtimeButton.fontSize = 40
        endtimeButton.fontColor = .gray
        endtimeButton.position = CGPoint(x: frame.midX - 100, y: frame.midY - 320)
        endtimeButton.name = "endModeButton" // タッチで識別できるよう名前を付ける
        addChild(endtimeButton)
        if endtime == "Endless" {
            showAlert(message: "エンドレスモードではスコアは保存されません")
        }
        if currentNight == "Dark" {backgroundColor = .black;if let tryagainLabel = childNode(withName: "restartButton") as? SKLabelNode {
            tryagainLabel.fontColor = .white
        }}
        let NightButton = SKLabelNode(text: "\(currentNight)")
        NightButton.fontSize = 40
        NightButton.fontColor = .gray
        NightButton.position = CGPoint(x: frame.midX+120, y: frame.midY - 320)
        NightButton.name = "NightButton" // タッチで識別できるよう名前を付ける
        addChild(NightButton)
    }
    
    
    func showRulesPage() {
        guard let viewController = self.view?.window?.rootViewController else { return }
        let rulesVC = RulesViewController()
        rulesVC.modalPresentationStyle = .fullScreen
        viewController.present(rulesVC, animated: true, completion: nil)
    }
    
    
    
    // ボタンのテキストを更新
    func updateSpeedButton() {
        if endtime == "Limited" {
            // アラートを表示して確認
            if !isSpecial{
                showConfirmationAlert { [weak self] confirmed in
                    guard let self = self else { return }
                    if confirmed {
                        // OKが押された場合、モードをエンドレスに変更
                        if let endModeButton = self.childNode(withName: "endModeButton") as? SKLabelNode {
                            self.endtime = "Endless"
                            previous_end_config = endtime
                            endModeButton.text = "Mode: \(self.endtime)"
                        }
                    }
                    // キャンセルの場合、何もしない
                }
            }else{
                showAlert(message: "スペシャルモードでは時間制限を外すことはできません。")
            }
        } else {
            // モードをリミテッドに変更
            if let endModeButton = childNode(withName: "endModeButton") as? SKLabelNode {
                endtime = "Limited"
                previous_end_config = endtime
                endModeButton.text = "Mode: \(endtime)"
            }
        }
    }
    
    func updateFontButtonText() {
        if currentFont == "HelveticaNeue-UltraLight" {
            currentFont = "TimesNewRomanPS-BoldMT"
            // ボタンのテキストをLightに変更
            if let fontChangeButton = childNode(withName: "fontChangeButton") as? SKLabelNode {
                fontChangeButton.text = "Bold"
                fontChangeButton.fontName = "TimesNewRomanPS-BoldMT"
                //print(fontChangeButton)
            }
        } else {
            currentFont = "HelveticaNeue-UltraLight"
            if let fontChangeButton = childNode(withName: "fontChangeButton") as? SKLabelNode {
                fontChangeButton.text = "Light"
                fontChangeButton.fontName = "HelveticaNeue-UltraLight"
            }
        }
    }
    
    func updateShapeButtonText() {
        if currentShape == "Cube" {
            currentShape = "Circle"
            if let shapeChangeButton = childNode(withName: "shapeChangeButton") as? SKLabelNode {
                shapeChangeButton.text = "Circle"
            }
        } else {
            currentShape = "Cube"
            if let shapeChangeButton = childNode(withName: "shapeChangeButton") as? SKLabelNode {
                shapeChangeButton.text = "Cube"
            }
        }
    }
    

    func updateNight() {
        if currentNight == "White" {
            currentNight = "Dark"
            backgroundColor = .black
            // ボタンのテキストをLightに変更
            if let tryagainLabel = childNode(withName: "restartButton") as? SKLabelNode {
                tryagainLabel.fontColor = .white
            }
        } else {
            currentNight = "White"
            if let nightButton = childNode(withName: "NightButton") as? SKLabelNode {
                nightButton.text = currentNight
                backgroundColor = .white
                if let tryagainLabel = childNode(withName: "restartButton") as? SKLabelNode {
                    tryagainLabel.fontColor = .black
                }
            }
        }
        print(currentNight)
    }
    //警告メッセ
    func showConfirmationAlert(completion: @escaping (Bool) -> Void) {
        guard let viewController = self.scene?.view?.window?.rootViewController else {
            completion(false)
            return
        }
        let alert = UIAlertController(
            title: "確認",
            message: "エンドレスモードではスコアは保存されませんがよろしいですか？",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: { _ in
            completion(false) // キャンセル時
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            completion(true) // OK時
        }))
        viewController.present(alert, animated: true, completion: nil)
    }
    func showAlert(message: String) {
        guard let viewController = self.scene?.view?.window?.rootViewController else {
            return
        }
        
        let alert = UIAlertController(
            title: "確認",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil)) // OKボタンのみ
        
        viewController.present(alert, animated: true, completion: nil)
    }


    // 難易度に応じたテキスト
    func difficultyText() -> String {
        switch difficulty {
        case .easy: 
            show_rank_level="easy"
            isSpecial = false
            if previous_end_config == "Endless"{
                if let endModeButton = childNode(withName: "endModeButton") as? SKLabelNode {
                    endtime = "Endless"
                    endModeButton.text = "Mode: \(endtime)"
                }
            }
            return "Easy"
        case .normal:show_rank_level="normal"; return "Normal"
        case .hard:show_rank_level="hard"; return "Hard"
        case .superHard:show_rank_level="superHard"; return "Super Hard"
        case .special: 
            show_rank_level="special"
            isSpecial = true
            if let endModeButton = self.childNode(withName: "endModeButton") as? SKLabelNode {
                self.endtime = "Limited"
                endModeButton.text = "Mode: \(self.endtime)"
            }
            return "Special"
        }
    }
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let node = atPoint(location)
            //print(node)
            createTouchCircle(at: location)
            
            
            if node.name == "difficultyLabel" {
                AudioManager.shared.playTapSound()
                // 難易度を切り替える
                switch difficulty {
                case .easy: difficulty = .normal
                case .normal: difficulty = .hard
                case .hard: difficulty = .superHard
                case .superHard: difficulty = .special
                case .special: difficulty = .easy
                }
                (node as? SKLabelNode)?.text = "Level: \(difficultyText())"
                //print((node as? SKLabelNode)?.text)
            }
            if node.name == "restartButton" {
                AudioManager.shared.playTapSound()
                // ゲームスタート
                let gameScene = GameScene(size: self.size)
                gameScene.difficulty = difficulty
                gameScene.scaleMode = .aspectFill
                view?.presentScene(gameScene, transition: .fade(withDuration: 1.0))
            } else if node.name == "muteButton" {
                // ミュート切り替え
                AudioManager.shared.toggleMute()
                if let muteLabel = node as? SKLabelNode {
                    muteLabel.text = AudioManager.shared.isAudioMuted() ? "Mute" : "Unmute"
                }
            }else if node.name == "fontChangeButton" {
                AudioManager.shared.playTapSound()
                updateFontButtonText()
            }else if node.name == "rulesButton" {
                AudioManager.shared.playTapSound()
                showRulesPage()
            }else if node.name == "shapeChangeButton" {
                AudioManager.shared.playTapSound()
                updateShapeButtonText()
            }else if node.name == "endModeButton" {
                AudioManager.shared.playTapSound()
                updateSpeedButton()
            }else if node.name == "NightButton"{
                AudioManager.shared.playTapSound()
                updateNight()
            }else if node.name == "ranking" {
                AudioManager.shared.playTapSound()
                let scoreScene = ScoreScene(size: self.size)
                scoreScene.finalScore = -1000000//関係ない
                scoreScene.show_rank_from_gameover = true
                scoreScene.difficulty =  show_rank_level// 難易度を渡す
                endtime = "Limited"
                if let endModeButton = self.childNode(withName: "endModeButton") as? SKLabelNode {
                    endModeButton.text = "Mode: \(self.endtime)"
                }
                scoreScene.endtime = self.endtime
                scoreScene.scaleMode = .aspectFill
                view?.presentScene(scoreScene, transition: .fade(withDuration: 1.0))
            }
            
        }
    }
}

