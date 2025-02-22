//11.21 2:14 end

import SwiftUI
import SpriteKit
import Foundation

enum Difficulty: Int, Codable {
    case easy = 0
    case normal = 1
    case hard = 2
    case superHard = 3
    case special = 4
}

//var my_username = "Roughfts"
//ユーザー名はここを変更　日本語可能　長すぎるのはやめてね
//""で挟んでね。必ず半角で。
var my_username = "Roughfts"
//他は一切触らないでね！



class GameScene: SKScene {
    var fontName: String = "HelveticaNeue-UltraLight" // 初期フォント
    var shape: String = "Cube"
    var speedMode: String = "Common"
    var endtime: String = "Limited"
    var ball: SKSpriteNode!
    var life = 5
    var lifeLabel: SKLabelNode! 
    var score = 0 
    var scoreLabel: SKLabelNode! 
    var combo = 0 
    var comboLabel: SKLabelNode!
    var levelLabel: SKLabelNode!
    var difficulty: Difficulty = .normal // 難易度を受け取るプロパティ
    var minnum = 14
    var maxnum = 498
    var gravity:Float = -3
    var combo_reset:Bool = true
    var upward_f = 150
    var M_spawn = 3
    var m_spawn = 3
    var level = "easy"
    var block_even_num = true
    var minus_score = false
    var xbsize = 80
    var ybsize = 65
    var miss = 0
    let start = Date()
    var currentNight = "White"
    var limit_time:Double = 120
    
    
    
    override func didMove(to view: SKView) {
        AudioManager.shared.playSound(fileName: "edm") // style.mp3を再生
        
        switch difficulty{
        case .easy:
            level = "easy"
            life = 7
            minnum = 8
            maxnum = 49
            combo_reset = false
            m_spawn = 2
            M_spawn = 4
            upward_f = upward_f * 2 / 3
            block_even_num = false
            limit_time=120
            physicsWorld.gravity = CGVector(dx: 0, dy: -1)
        case .normal:
            level = "normal"
            life = 4
            minnum = 13
            maxnum = 68
            combo_reset = false
            m_spawn = 2
            M_spawn = 4
            block_even_num = true
            limit_time=120
            physicsWorld.gravity = CGVector(dx: 0, dy: -2.8)
        case .hard:
            level="hard"
            life = 8
            minnum = 39
            maxnum = 130
            m_spawn = 2
            M_spawn = 4
            limit_time=90
            minus_score = true
            block_even_num = true
            physicsWorld.gravity = CGVector(dx: 0, dy: -3)
        case .superHard:
            level="superHard"
            life = 5
            minnum = 200
            maxnum = 1999
            gravity = -4
            upward_f = 200
            limit_time=120
            m_spawn = 3
            M_spawn = 4
            minus_score = true
            physicsWorld.gravity = CGVector(dx: 0, dy: -5.2)
        case .special:
            level="special"
            life = 35
            m_spawn = 4
            M_spawn = 6
            speedMode = "Speedy"
            physicsWorld.gravity = CGVector(dx: 0, dy: -3)
        }
        self.isUserInteractionEnabled = true
        //life = 1
        // 物理エンジンを有効にする
        
        if let gameOverScene = view.scene as? GameOverScene {
            fontName = gameOverScene.currentFont
            shape = gameOverScene.currentShape
            endtime = gameOverScene.endtime
            currentNight = gameOverScene.currentNight
        }
        if currentNight == "White"{backgroundColor = .white}else{backgroundColor = .black}
        
        // ライフラベルの作成
        lifeLabel = SKLabelNode(text: "Life: \(life)")
        lifeLabel.fontSize = 30
        lifeLabel.fontColor = .black
        if currentNight == "Dark" {lifeLabel.fontColor = .white}
        lifeLabel.position = CGPoint(x: frame.midX-180, y: frame.maxY - 55) // 画面上部に配置
        lifeLabel.name = "lifeLabel"  // ラベルに名前を設定
        addChild(lifeLabel)
        
        scoreLabel = SKLabelNode(text: "Score: \(score)")
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = .black
        if currentNight == "Dark" {scoreLabel.fontColor = .white}
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 55) // 画面上部に配置
        scoreLabel.name = "scoreLabel"  // ラベルに名前を設定
        addChild(scoreLabel)
        // ライフラベルの作成
        comboLabel = SKLabelNode(text: "Combo: \(combo)")
        comboLabel.fontSize = 30
        comboLabel.fontColor = .black
        if currentNight == "Dark" {comboLabel.fontColor = .white}
        comboLabel.position = CGPoint(x: frame.midX+180, y: frame.maxY - 55) // 画面上部に配置
        comboLabel.name = "comboLabel"  // ラベルに名前を設定
        addChild(comboLabel)
        // levelLabelの作成
        levelLabel = SKLabelNode(text: "\(level)")
        levelLabel.fontSize = 30
        levelLabel.fontColor = .black
        if currentNight == "Dark" {levelLabel.fontColor = .white}
        levelLabel.position = CGPoint(x: frame.midX-350, y: frame.maxY - 55) // 画面上部に配置
        levelLabel.name = "comboLabel"  // ラベルに名前を設定
        addChild(levelLabel)
        
        let menuButton = SKLabelNode(text: "≡")
        menuButton.fontSize = 60
        menuButton.fontColor = .black
        if currentNight == "Dark" {menuButton.fontColor = .white}
        menuButton.zPosition = 120
        menuButton.position = CGPoint(x: frame.minX+40, y: frame.maxY - 60) // 画面上部に配置
        menuButton.name = "menuButton"  // ラベルに名前を設定
        addChild(menuButton)
        
        // 左右のみに当たり判定を設定
        let leftWall = SKNode()
        leftWall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: frame.minX, y: frame.minY),
                                             to: CGPoint(x: frame.minX, y: frame.maxY))
        addChild(leftWall)
        
        let rightWall = SKNode()
        rightWall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: frame.maxX, y: frame.minY),
                                              to: CGPoint(x: frame.maxX, y: frame.maxY))
        addChild(rightWall)
        
        if speedMode == "special"{
            let upWall = SKNode()
            upWall.physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: frame.minY, y: frame.maxY),
                                                  to: CGPoint(x: frame.maxX, y: frame.maxY))
            addChild(upWall)
            
        }
        let spawnBallAction = SKAction.run { [weak self] in
            guard let self = self else { return }
            
            // 難易度が "easy" の場合は、条件を満たすまで待つ
            if self.level == "easy" {
                self.checkAndSpawnBalls()
            } else {
                // 他の難易度では通常通りボールをスポーン
                self.spawnBalls()
            }
        }
        let spawnDelay = SKAction.wait(forDuration: level=="easy" ? 1.5 : 3) // 3秒おきに実行
        let spawnSequence = SKAction.sequence([spawnBallAction, spawnDelay])
        run(SKAction.repeatForever(spawnSequence))
    }
    
    private func checkAndSpawnBalls() {
        // 画面上のボールの数を確認
        let currentBalls = children.filter { $0.name == "ball" } 
        if currentBalls.count <= 1 {
            spawnBalls() 
        }
    }
    
    // ボールを画面外に消えたものを削除する
    func cleanUpBalls() {
        //print("クリーンアップアクション開始")
        for node in children {
            //print("ノードは\(node)")
            //print("ノードタイプ: \(type(of: node))") // ノードの型を表示
            if let ball = node as? SKSpriteNode {
                //print("ボールの位置: \(ball.position)") // ボールの位置を表示
                if ball.position.y < frame.minY { // 画面外に出たら削除
                    //print("画面外のボール発見: \(ball.position)") // 画面外のボールを表示
                    //ball.removeFromParent()
                }
            }
        }
        //print("クリーンアップ終了")
    }
    
    // ボールをランダムに配置
    func spawnBalls() {
        // 1〜3個のボールを同時に生成
        let numBalls = Int.random(in: m_spawn...M_spawn)
        
        var xPositions: [CGFloat] = []
        
        // 既存のボールの位置を取得
        let existingBalls = self.children.compactMap { $0 as? SKSpriteNode }
        
        for _ in 0..<numBalls {
            var xPosition: CGFloat
            repeat {
                // ランダムに配置し、ボール同士の横幅の余白を確保
                xPosition = CGFloat.random(in: 50...(size.width - 50))
            } while xPositions.contains(where: { abs($0 - xPosition) < 100 }) // 100はボール同士の最小間隔
            xPositions.append(xPosition)
            
            // 新しいボールを生成
            let newBall = createBall(isInitial: true) // 最初のボールにはランダムな数字
            newBall.position = CGPoint(x: xPosition, y: 40) // 画面下部に配置
            addChild(newBall)
            
            // 他のボールとの位置関係を計算
            var shouldDoubleImpulse = false
            for existingBall in existingBalls {
                let deltaY = existingBall.position.y - newBall.position.y
                let deltaX = abs(existingBall.position.x - newBall.position.x)
                
                if deltaY >= 80, deltaY <= 250, deltaX <= 100 {
                    shouldDoubleImpulse = true
                    break
                }
            }
            //if shouldDoubleImpulse{newBall.position = CGPoint(x: xPosition, y: frame.maxY+100)}
            if shouldDoubleImpulse{
                let impulseY = 100
                if Int.random(in: 0...2)>1{//右から
                    newBall.position = CGPoint(x: frame.maxX, y: frame.midY)
                    let upwardImpulse = CGVector(dx: .random(in: 50...100), dy: impulseY)
                    newBall.physicsBody?.applyImpulse(upwardImpulse)
                }else{//左から
                    newBall.position = CGPoint(x: frame.minX, y: frame.midY)
                    let left_impulse = -50
                    let upwardImpulse = CGVector(dx: .random(in: -100...left_impulse), dy: impulseY)
                    newBall.physicsBody?.applyImpulse(upwardImpulse)
                }
                
            }else{
                let impulseY = shouldDoubleImpulse ? 50 : upward_f
                let left_impulse = shouldDoubleImpulse ? 20 : 8
                let upwardImpulse = CGVector(dx: .random(in: -left_impulse...left_impulse), dy: impulseY)
                newBall.physicsBody?.applyImpulse(upwardImpulse)
            }
            // 上方向に初速を与える
            
        }
    }
    
    
    
    
    
    // マーブル模様の作成
    func createMarbleTexture(size: CGSize) -> SKTexture {
        let imageSize = CGSize(width: size.width * 2, height: size.height * 2)
        UIGraphicsBeginImageContext(imageSize)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            return SKTexture()
        }
        // グラデーションの開始点と終了点をランダムに設定
        let startPoint = CGPoint(x: 0,y: 0)
        let endPoint = CGPoint(x: imageSize.width,y: imageSize.height)
        // グラデーションの背景を描画
        let colors = [UIColor.blue.cgColor, UIColor.cyan.cgColor]
        let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: nil)!
        context.drawLinearGradient(gradient,
                                   start: startPoint,
                                   end: endPoint,
                                   options: [])
        let marbleImage = UIGraphicsGetImageFromCurrentImageContext()!
        // 回転を適用
        let rotatedImage = rotateImage(image: marbleImage, angle: CGFloat.random(in: 0...360))
        // テクスチャを作成
        return SKTexture(image: rotatedImage)
    }
    
    // 画像を回転させる関数
    func rotateImage(image: UIImage, angle: CGFloat) -> UIImage {
        let radians = angle * .pi / 180
        let rotatedSize = CGSize(width: image.size.width, height: image.size.height)
        
        UIGraphicsBeginImageContext(rotatedSize)
        guard let context = UIGraphicsGetCurrentContext() else {
            return image
        }
        
        // 中心を移動してから回転
        context.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        context.rotate(by: radians)
        image.draw(in: CGRect(x: -image.size.width / 2, y: -image.size.height / 2, width: image.size.width, height: image.size.height))
        
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return rotatedImage
    }
    
    

    // ボールを作成するメソッド
    func createBall(isInitial: Bool) -> SKSpriteNode {
        let radius: CGFloat = 40 // 円の半径
        let size: CGSize = CGSize(width: radius * 2, height: radius * 2) // 正方形と円の共通サイズ
        // ボールを生成
        let newBall = SKSpriteNode(texture: nil, color: .clear, size: size)
        newBall.name = "ball"
        
        if shape == "Circle" {
            //showCompositeNumberText(text: "Circle")
            // 円形を描画
            let shapeNode = SKShapeNode(circleOfRadius: radius)
            let marbleTexture = createMarbleTexture(size: size)
            shapeNode.fillTexture = marbleTexture
            shapeNode.fillColor = .white// ランダムな色
            shapeNode.strokeColor = .clear
            shapeNode.lineWidth = 2.0
            shapeNode.position = CGPoint(x: 0, y: 0)
            shapeNode.zPosition = 0
            newBall.addChild(shapeNode)
            
            // 円形の物理ボディを設定
            newBall.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        } else if shape == "Cube" {
            // 四角形を描画
            let shapeNode = SKShapeNode(rectOf: CGSize(width: xbsize, height: ybsize))
            shapeNode.fillColor = .orange // ランダムな色
            shapeNode.lineWidth = 2.0
            shapeNode.position = CGPoint(x: 0, y: 0)
            shapeNode.zPosition = 0
            newBall.addChild(shapeNode)
            newBall.size = CGSize(width: xbsize, height: ybsize)
            // 四角形の物理ボディを設定
            newBall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: xbsize, height: ybsize))
        }
        
        newBall.physicsBody?.isDynamic = true
        newBall.physicsBody?.allowsRotation = false
        newBall.physicsBody?.friction = 0
        newBall.physicsBody?.restitution = 0.8
        newBall.physicsBody?.angularDamping = 0
        newBall.physicsBody?.mass = 0.23
        
        if isInitial {
            // 最初のボールにはランダム
            var randomNumber = 0
            while randomNumber % 5 == 0{
                //print("えへへ")
                if block_even_num {
                    randomNumber = Int.random(in: minnum...maxnum) * 2 + 1// 2〜867の数字
                    if level == "superHard"{if randomNumber % 3 == 0{randomNumber=0}}
                }else{
                    randomNumber = Int.random(in: minnum...maxnum*2)// 2〜867の数字
                }
                    
            }
            if speedMode == "Speedy" {randomNumber = 243}
            //let numberLabel = createStyledLabel(text: "\(randomNumber)", size: radius)
            let numberLabel = SKLabelNode(text: "\(randomNumber)")
            numberLabel.fontSize = 40
            numberLabel.fontName = fontName
            if shape == "Circle"{
                numberLabel.fontColor = .white
            }else{
                numberLabel.fontColor = .black
            }
            
            numberLabel.position = CGPoint(x: 0, y: -10)
            numberLabel.name = "numberLabel"  // ラベルに名前を設定
            newBall.addChild(numberLabel)
        }
        
        return newBall
    }
    
    // スワイプ時の追尾用ライン
    private var swipeTrail: SKShapeNode?
    private var sliceOK = true
    private var up_slOK = true
    private var swipecheckinterval = 200
    private var isSwiping = false
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        //let node = atPoint(location)
        print("Touched node: \(atPoint(location).name ?? "None")")

        
        if speedMode == "Speedy" {
            swipecheckinterval = 100
        }
        isSwiping = false
        
        sliceOK = true
        // タッチエフェクトを表示
        createTouchCircle(at: location)
        //showMenu()
        // メニューのタップ判定を優先
        if atPoint(location).name == "menuButton" {
            AudioManager.shared.playTapSound()
            let gameOverScene = GameOverScene(size: self.size)
            gameOverScene.scaleMode = .aspectFill
            view?.presentScene(gameOverScene, transition: .fade(withDuration: 1.0))
        }
        // タップ処理
        checkBallInteraction(at: location)
        
        // スワイプ用のラインを作成
        swipeTrail = SKShapeNode()
        if currentNight == "Dark"{
            swipeTrail?.strokeColor = .yellow
        }else{
            swipeTrail?.strokeColor = .blue
        }
        swipeTrail?.lineWidth = 2
        swipeTrail?.zPosition = -3
        addChild(swipeTrail!)
        
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let currentLocation = touch.location(in: self)
        let previousLocation = touch.previousLocation(in: self)
        isSwiping = true
        // スワイプエフェクトを更新
        if let swipeTrail = swipeTrail {
            let path = CGMutablePath()
            path.move(to: previousLocation)
            path.addLine(to: currentLocation)
            swipeTrail.path = path
        }
        
        // スワイプ時のボール判定
        if upcount > swipecheckinterval{checkBallInteraction(at: currentLocation)}
        if nodes(at: currentLocation).isEmpty {
            sliceOK = true
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // スワイプ終了時にラインを削除
        swipeTrail?.removeFromParent()
        isSwiping = false
        sliceOK = true
        swipeTrail = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded(touches, with: event) // 同じ終了処理を呼び出し
    }
    
    /// タップまたはスワイプ時にボールの判定を行う
    func checkBallInteraction(at location: CGPoint) {
        let node = atPoint(location)
        
        // ボールがラベルではなく直接タップされた場合
        if let parentNode = node.parent as? SKSpriteNode, parentNode.name == "ball" {
            if sliceOK {handleBallInteraction(parentNode)}
        } 
        // ボール自体がタップされた場合
        else if let ballNode = node as? SKSpriteNode, ballNode.name == "ball" {
            if sliceOK {handleBallInteraction(ballNode)}
        }
    }
    
    /// ボールに触れた際の処理
    func handleBallInteraction(_ ball: SKSpriteNode) {
        AudioManager.shared.playTapSound()
        //up_slOK = false
        upcount = 0
        sliceOK = false
        up_slOK = false
        splitBall(ball)
        up_slOK = true
    }
    

    
    // タッチ時に円を作成するメソッド
    func createTouchCircle(at position: CGPoint) {
        let circle = SKShapeNode(circleOfRadius: 10) // 半径10の円
        circle.fillColor = .clear // 塗りつぶしなし
        circle.strokeColor = .black // 線の色を黒に
        circle.lineWidth = 2 // 線の太さを2に設定
        circle.position = position
        // ボールのタップ判定に影響しないように設定
        circle.zPosition = -1 // 背景レイヤーに置く
        circle.isUserInteractionEnabled = false
        addChild(circle)
        // アニメーションでフェードアウト＆拡大しながら消える
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.3)
        let group = SKAction.group([fadeOut, scaleUp])
        let remove = SKAction.removeFromParent()
        circle.run(SKAction.sequence([group, remove]))
    }
    // 合成数の最小因数を求める関数
    func smallestFactor(of number: Int) -> Int? {
        guard number > 1 else { return nil }
        for i in 2...Int(sqrt(Double(number))) {
            if number % i == 0 {
                return i
            }
        }
        return nil // 素数の場合は nil を返す
    }

    private var upcount = 0
    override func update(_ currentTime: TimeInterval) {
        for child in children {            
            upcount += 1
            //print(upcount)
            if upcount > swipecheckinterval && up_slOK {sliceOK = true}
            if !minus_score{if score<0{score=0}}
            updateScoreLabel()
            if let ball = child as? SKSpriteNode, ball.position.y > size.height + 300 {
                ball.removeFromParent()
            }else if let ball = child as? SKSpriteNode, ball.position.y < -size.height / 2 {
                //print("c")
                guard let numberLabel = ball.childNode(withName: "numberLabel") as? SKLabelNode,
                      let numberText = numberLabel.text,
                      let number = Int(numberText) else {
                    print("ラベルが見つからないか、数字の変換に失敗しました")
                    return
                }
                if level == "easy" && number != 2 && number != 3{
                    if number % 2 == 0 || number % 3 == 0{
                        miss += 1
                        showCompositeNumberText(text: "Miss: \(miss)")
                        if miss >= 4{
                            miss=0
                            life -= 1
                            showCompositeNumberText(text: "Life -1")
                            updateLifeLabel()
                            checkGameOver()
                        }
                        
                    }
                }else if number == 243 || number==81{
                    miss += 1
                    showCompositeNumberText(text: "Miss: \(miss)")
                    if miss >= 4{
                        miss=0
                        life -= 1
                        showCompositeNumberText(text: "Life -1")
                        updateLifeLabel()
                        checkGameOver()
                    }
                }else{
                    if  number >= 82 {
                        //print("d")
                        if let factor = smallestFactor(of: number) {
                            if factor != number{
                                score -= factor
                                //print("factor")
                                let text = " \(number) = \(factor) × \(number / factor)"
                                showCompositeNumberText(text: "Score: -\(factor)")
                                showCompositeNumberText(text: text)
                            }
                        }
                    }
                }
                
                ball.removeFromParent() // ボールを削除
            }
            
            if endtime == "Limited"{
                let elapsed = Date().timeIntervalSince(start)
                if elapsed >= limit_time && ended_bytime{
                    ended_bytime=false
                    gameOver()
                }
            }            
        }
    }
    private var ended_bytime = true
    var compositeTextLabels: [SKLabelNode] = [] // 表示中のテキストを管理する配列
    
    func showCompositeNumberText(text: String) {
        let label = SKLabelNode(text: text)
        label.fontSize = 26
        label.fontColor = .black
        if currentNight == "Dark" {label.fontColor = .white}
        label.position = CGPoint(x: frame.maxX - 120, y: frame.maxY - 55)
        label.alpha = 0 // 初期状態では透明
        addChild(label)
        
        // フェードイン → 少し表示 → フェードアウト
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let wait = SKAction.wait(forDuration: 2.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.run { [weak self] in
            // 配列から削除し、画面からも削除
            if let index = self?.compositeTextLabels.firstIndex(of: label) {
                self?.compositeTextLabels.remove(at: index)
            }
            label.removeFromParent()
        }
        let sequence = SKAction.sequence([fadeIn, wait, fadeOut, remove])
        label.run(sequence)
        
        // 古いラベルを下に移動
        adjustExistingLabels()
        
        // 新しいラベルを管理リストに追加
        compositeTextLabels.append(label)
        
        // 最大数を超えた場合、最古のラベルを削除
        if compositeTextLabels.count > 5 {
            if let oldestLabel = compositeTextLabels.first {
                compositeTextLabels.removeFirst()
                oldestLabel.removeFromParent()
            }
        }
    }
    
    func adjustExistingLabels() {
        // 既存のラベルを下に移動（新しいラベルのスペースを作る）
        for label in compositeTextLabels {
            let moveDown = SKAction.moveBy(x: 0, y: -30, duration: 0.3) // 下に移動
            label.run(moveDown)
        }
    }


 
    
    // 最小の素因数を返す関数
    func smallestPrimeFactor(_ number: Int) -> Int {
        if number <= 1 { return number }
        if number % 2 == 0 { return 2 }
        for i in stride(from: 3, through: Int(sqrt(Double(number))), by: 2) {
            if number % i == 0 {
                return i
            }
        }
        return number // 素数の場合はそのまま返す
    }
    func displayScoreChange(at position: CGPoint, score: Int) {
        // スコアテキストの作成
        
        let scoreLabel = SKLabelNode(text: score > 0 ? "+\(score)" : "\(score)")
        scoreLabel.fontName = "Arial"
        scoreLabel.fontSize = 30
        scoreLabel.fontColor = score > 0 ? .blue : .red
        scoreLabel.zPosition = 1
        scoreLabel.position = CGPoint(x: position.x, y: position.y+30) // ボールの上から少し下にオフセット
        addChild(scoreLabel)
        
        // 下から上に動かすアニメーションを作成
        //let moveUp = SKAction.moveBy(x: 0, y: 30, duration: 0.25)  // 60ポイント上に移動
        //let fadeIn = SKAction.fadeIn(withDuration: 0.5)  // fade in
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)  //fade out
        let remove = SKAction.removeFromParent()
        // アニメーションの実行
        scoreLabel.run(SKAction.sequence([fadeOut, remove]))
    }
    // ボールを分裂させるメソッド
    func splitBall(_ ball: SKSpriteNode) {
        // 分裂可能か確認
        guard ball.canSplit else {
            //score = -100000
            //showCompositeNumberText(text: "\(-100000)")
            //showCompositeNumberText(text: "連打:お仕置きよ❤︎")
            print("このボールは分裂できません")
            return
        }
        let ballposition = ball.position
        // 分裂中に再度分裂されないようフラグを無効化
        ball.canSplit = false
        guard let numberLabel = ball.childNode(withName: "numberLabel") as? SKLabelNode,
              let velocity = ball.physicsBody?.velocity,
              let numberText = numberLabel.text,
              let number = Int(numberText) else {
            print("ラベルが見つからないか、数字の変換に失敗しました")
            return
        }
        let yVelocity = velocity.dy
        let primeFactor=smallestPrimeFactor(number)
        if primeFactor==number {
            // 素数の場合
            life -= 1
            combo = 0
            var minusg = -number * 2
            if level == "superHard"{
                minusg -= 1000
            }else{
                minusg -= 120
            }
            if yVelocity > 0{minusg = minusg * 3 / 2}
            score += minusg
            showCompositeNumberText(text: "\(number) is prime: \(minusg)")
            displayScoreChange(at: ballposition, score: minusg)
            
            if life != 0{
                //if score <= 0{score=0}
                //score=51
                if combo_reset{if score > 0 {score/=2}}
            }
            updateLifeLabel()
            checkGameOver()
            ball.texture = nil
            ball.color = .clear
            let changeToBlue = SKAction.colorize(with: .blue, colorBlendFactor: 1.0, duration: 0.2)
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let removeNode = SKAction.removeFromParent()
            if shape == "Cube"{
                ball.run(SKAction.sequence([
                    changeToBlue,
                    fadeOut,
                    removeNode
                ]))
            }else{
                ball.run(SKAction.sequence([
                    fadeOut,
                    removeNode
                ]))
            }
            
        } else {
            // 合成数の場合
            var spt = 1
            if yVelocity > 0{spt=2}
            combo += 1
            let quotient = number / primeFactor
            let g = number * (1+combo/2) * spt
            score += Int(g)
            displayScoreChange(at: ballposition, score: g)
            for i in 0..<2 {
                
                let newBall = createBall(isInitial: false)
                if i == 0{
                    
                    newBall.size = CGSize(width: xbsize, height: ybsize)
                    newBall.physicsBody?.mass=0.1
                    newBall.physicsBody?=SKPhysicsBody(rectangleOf: newBall.size)
                    newBall.physicsBody?.allowsRotation=false
                }
                //xbsize=90;ybsize=50
                newBall.position = ball.position
                
                let newNumber: Int = (i == 0) ? quotient : primeFactor
                let numberLabel = SKLabelNode(text: "\(newNumber)")
                numberLabel.fontSize = 40
                numberLabel.fontName = fontName
                if shape == "Cube"{
                    numberLabel.fontColor = .black
                }else{
                    numberLabel.fontColor = .white
                }
                numberLabel.position = CGPoint(x: 0, y: -10)
                numberLabel.name = "numberLabel"
                newBall.addChild(numberLabel)
                addChild(newBall)
                var randomXVelocity = CGFloat.random(in: 100...200)
                var randomYVelocity = CGFloat.random(in: 120...200)
                if i == 0{randomXVelocity *= -1;randomYVelocity *= -1}
                
                if level == "easy"{randomXVelocity/=2;randomYVelocity/=2}
                newBall.physicsBody?.velocity = CGVector(dx: randomXVelocity, dy: randomYVelocity)
                
                // 分裂直後のボールも分裂可能に設定
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    newBall.canSplit = true
                }
            }
            ball.texture = nil
            ball.color = .clear
            let changeToYellow = SKAction.colorize(with: .yellow, colorBlendFactor: 1.0, duration: 0.2)
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let removeNode = SKAction.removeFromParent()
            if shape == "Cube"{
                ball.run(SKAction.sequence([
                    changeToYellow,
                    fadeOut,
                    removeNode
                ]))
            }else{
                ball.run(SKAction.sequence([
                    fadeOut,
                    removeNode
                ]))
            }
            
            
        }
        updateComboLabel()
    
    }

    
    
    
    func updateLifeLabel() {
        lifeLabel.text = "Life: \(life)"
    }
    func updateScoreLabel() {
        scoreLabel.text = "Score: \(score)"
    }
    func updateComboLabel() {
        comboLabel.text = "Combo: \(combo)"
    }
    func gameOver() {
        // スコアを保存
        //if speedMode == "Common" {saveScore(score: score, for: level)}else{print("Specialモードなのでスコアは保存できません")}
        
        if endtime == "Limited"{saveScoreToFirebase(score: score, userName: my_username, difficulty: level)}

        // ScoreSceneに遷移する
        let scoreScene = ScoreScene(size: self.size)
        scoreScene.finalScore = self.score
        scoreScene.difficulty = self.level // 難易度を渡す
        scoreScene.endtime = self.endtime
        scoreScene.scaleMode = .aspectFill
        view?.presentScene(scoreScene, transition: .fade(withDuration: 1.0))
    }
    
    // スコアを保存してランキングを更
    

    
    
    
    
    func saveScoreToFirebase(score: Int, userName: String, difficulty: String) {
        let databaseURL = "https://split-to-prime-default-rtdb.firebaseio.com/scores/\(difficulty).json"
        guard let url = URL(string: databaseURL) else { return }
        
        // Step 1: 新しいスコアを追加 (POST)
        let newScoreData: [String: Any] = [
            "score": score,
            "userName": userName,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: newScoreData) else { return }
        
        var postRequest = URLRequest(url: url)
        postRequest.httpMethod = "POST"
        postRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        postRequest.httpBody = jsonData
        
        let postTask = URLSession.shared.dataTask(with: postRequest) { _, _, error in
            if let error = error {
                print("スコア追加エラー: \(error.localizedDescription)")
                return
            }
            
            print("スコアが追加されました！")
            
            // Step 2: 全スコアを取得して処理
            self.retrieveAndSortScores(for: difficulty, databaseURL: databaseURL)
        }
        postTask.resume()
    }
    
    func retrieveAndSortScores(for difficulty: String, databaseURL: String) {
        guard let url = URL(string: databaseURL) else { return }
        
        var getRequest = URLRequest(url: url)
        getRequest.httpMethod = "GET"
        
        let getTask = URLSession.shared.dataTask(with: getRequest) { data, _, error in
            if let error = error {
                print("スコア取得エラー: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else { return }
            var allScores: [[String: Any]] = []
            
            // JSONデコード
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] {
                allScores = json.values.compactMap { $0 }
            }
            
            // スコアを降順でソートし、上位5件を取得
            let sortedScores = allScores.sorted {
                guard let score1 = $0["score"] as? Int, let score2 = $1["score"] as? Int else { return false }
                return score1 > score2
            }
            let top5Scores = Array(sortedScores.prefix(10))
            
            // 上位5件を保存 (PUT)
            self.updateTopScores(top5Scores, for: difficulty, databaseURL: databaseURL)
        }
        getTask.resume()
    }
    
    func updateTopScores(_ scores: [[String: Any]], for difficulty: String, databaseURL: String) {
        guard let url = URL(string: databaseURL) else { return }
        
        var putRequest = URLRequest(url: url)
        putRequest.httpMethod = "PUT"
        putRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: scores) else { return }
        putRequest.httpBody = jsonData
        
        let putTask = URLSession.shared.dataTask(with: putRequest) { _, _, error in
            if let error = error {
                print("上位スコア保存エラー: \(error.localizedDescription)")
            } else {
                print("上位スコアが更新されました！")
            }
        }
        putTask.resume()
    }
    
    
    
    // テスト用
    //saveScoreToFirebase(score: 300, userName: "Eve", difficulty: "medium")

    
    

    
    

    
    

    // ゲームオーバーチェック
    func checkGameOver() {
        if life <= 0 {
            gameOver()
        }
    }   

}



struct ContentView: View {
    
    var body: some View {
        // SKViewを表示
        SpriteView(scene: initialScene()) // 初期シーンを指定
            .ignoresSafeArea() // セーフエリアを無視して画面全体を使用
        
    }
    
    // 初期シーンを設定する関数
    func initialScene() -> SKScene {
        let gameOverScene = GameOverScene(size: CGSize(width: 1024, height: 768)) // 初期画面としてGameOverSceneを使用
        gameOverScene.scaleMode = .aspectFill
        
        return gameOverScene
    }
}

