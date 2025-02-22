import UIKit

class RulesViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        let scrollView = UIScrollView(frame: view.bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.contentSize = CGSize(width: view.frame.width, height: 2900) // コンテンツの高さを設定
        // スクロールインジケーターのスタイルと色
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.indicatorStyle = .black
        // スクロールインジケーターのインセット調整
        scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
        view.addSubview(scrollView)


        // 戻るボタン
        let backButton = UIButton(type: .system)
        backButton.setTitle("戻る", for: .normal)
        backButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        backButton.frame = CGRect(x: 0, y: view.safeAreaInsets.top + 30, width: 100, height: 40)
        backButton.addTarget(self, action: #selector(backToGameOver), for: .touchUpInside)
        view.addSubview(backButton)
        
        
        let titleTextLabel = UILabel()
        titleTextLabel.text = """
        ーーーーー素数は無視！素数じゃないやつはタップかスワイプ！ーーーーー
        """
        titleTextLabel.font = UIFont.systemFont(ofSize: 25)
        titleTextLabel.textColor = .red
        titleTextLabel.numberOfLines = 0
        titleTextLabel.frame = CGRect(x: 120, y: -50, width: scrollView.frame.width - 40, height: 200)
        scrollView.addSubview(titleTextLabel)
        
        // テキストラベルを追加
        let textLabel = UILabel()
        textLabel.text = """
        
        ゲームのルール説明:
        
        1. 下から出てくる＜合成数＞のキューブをタップまたはスライスして、素数と商に分割し、スコアを稼ぎます。
                毎回タップとスワイプというのが面倒なので、ボールを分裂させることをタップと呼称します。
        2. 素数をタップしてしまうと、キューブが青くなり、スコアが減点され、
            
            ライフが減少します。コンボもリセットします。
        
        3. 合成数を画面外に逃してしまうと、スコアが減点されます。
        
        4. 合成数をタップすると、キューブが黄色くなり、タップした合成数がそのままスコアに加算されます。
        
        5. 画面右上には、逃してしまった合成数の、最小素因数を表示してくれる機能があります。
                
                ↑この表示を見て勉強するのもありですよ！
        
        6. 最初はEasyモードで、慣れればNormalモードで遊びましょう！制限時間は1分です。
        
        7. ボールを早めに分裂させたら、score加算が2倍です。(ボールが上に上がっているタイミング)
            
        8. スペシャルレベルは単純に爽快さです。
        """
        textLabel.font = UIFont.systemFont(ofSize: 18)
        textLabel.textColor = .black
        textLabel.numberOfLines = 0
        textLabel.frame = CGRect(x: 130, y: 50, width: scrollView.frame.width - 40, height: 500)
        scrollView.addSubview(textLabel)
        
        // 写真を追加
        let imageView = UIImageView(image: UIImage(named: "gamescene")) // 画像名を適切に置き換えてください
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 0, y: 560, width: scrollView.frame.width - 40, height: 280)
        scrollView.addSubview(imageView)
        
        // 写真の説明ラベル-
        let imageDescriptionLabel = UILabel()
        imageDescriptionLabel.text = """
        上の画像は、ゲームプレイ中のものです。
        ゲーム中には、左から
        
            ・現在のレベル設定
            ・ライフ
            ・スコア
            ・コンボ
            ・ヒントやスコアの足し引きの表示
        
        が表示されます。
        
        コンボを重ねると、スコアに加算される点数がそのスコアの分だけ5分の1、倍加されます。
        
        
        次に、それぞれのレベルについての設定です。レベルによって処理や設定がかなり違います。
        
        なので、レベルを超えてスコア比較するのはナンセンスです。
        """
        imageDescriptionLabel.font = UIFont.systemFont(ofSize: 18)
        imageDescriptionLabel.textColor = .black
        imageDescriptionLabel.numberOfLines = 0
        imageDescriptionLabel.frame = CGRect(x: 130, y: 840, width: scrollView.frame.width - 40, height: 380)
        scrollView.addSubview(imageDescriptionLabel)
        
        
        // 表を作成してスクロールビューに追加
        let rulesTable = createRulesTable()
        rulesTable.frame = CGRect(x: 0, y: 1240, width: view.frame.width - 100, height: 400)
        scrollView.addSubview(rulesTable)
    
        // さらにテキストを追加-
        let secondTextLabel = UILabel()
        secondTextLabel.text = """
        また、easyモードでは特徴的に、2の倍数か3の倍数の合成数が落ちてしまった時、Missという判定があります。
        
        このMissが4個貯まると、ライフが1減ります。
        
        また、全てのレベルを通して、78以上の合成数が落ちてしまった時、その最小素因数がスコアから引かれます。
        
        また、80以上の合成数のみ、右上にヒントが出るようになっています。
        """
        secondTextLabel.font = UIFont.systemFont(ofSize: 18)
        secondTextLabel.textColor = .black
        secondTextLabel.numberOfLines = 0
        secondTextLabel.frame = CGRect(x: 130, y: 1650, width: scrollView.frame.width - 40, height: 200)
        scrollView.addSubview(secondTextLabel)
        
        let uimage = UIImageView(image: UIImage(named: "reload")) // 画像名を適切に置き換えてください
        uimage.contentMode = .scaleAspectFit
        uimage.frame = CGRect(x: 0, y: 1940, width: scrollView.frame.width - 40, height: 100)
        scrollView.addSubview(uimage)
        
        
        
        let thirdTextLabel = UILabel()
        thirdTextLabel.text = """
        ゲームがうまく読み込まれなかった時は、動かして最初に出る↑の画像の、
        
        一番右のマークを押してください。
        
        また、アプリを終了する場合は、そのままホーム画面に移ったり、タスクを切っても大丈夫です。
        
        ただ、ちょうどさっき記録した自己ベストのデータが飛ぶ可能性があります。
        
        あと、キャッシュ的にあんまりよくなさそうなので、
        
        このゲームを動かした時に画面右上に表示されるオレンジ色の飛んでいる鳥（swiftのロゴ）を押してください。
        
        そうすると、
        """
        thirdTextLabel.font = UIFont.systemFont(ofSize: 18)
        thirdTextLabel.textColor = .black
        thirdTextLabel.numberOfLines = 0
        thirdTextLabel.frame = CGRect(x: 130, y: 2050, width: scrollView.frame.width - 40, height: 300)
        scrollView.addSubview(thirdTextLabel)
        
        let endw = UIImageView(image: UIImage(named: "window")) // 画像名を適切に置き換えてください
        endw.contentMode = .scaleAspectFit
        endw.frame = CGRect(x: 0, y: 2400, width: scrollView.frame.width - 40, height: 380)
        scrollView.addSubview(endw)
        
        let forthTextLabel = UILabel()
        forthTextLabel.text = """
        が出ますので、停止をすると安全にゲームを閉じることができます。
        
        ちなみにここの再起動のボタンを押すと、ライフに関係なくゲーム終了画面に飛ぶことができます。
        """
        forthTextLabel.font = UIFont.systemFont(ofSize: 18)
        forthTextLabel.textColor = .black
        forthTextLabel.numberOfLines = 0
        forthTextLabel.frame = CGRect(x: 130, y: 2750, width: scrollView.frame.width - 40, height: 200)
        scrollView.addSubview(forthTextLabel)
    }
    
    func createRulesTable() -> UIView {
        let tableView = UIView()
        
        // ヘッダー定義
        let headers: [String] = ["Level", "Easy", "Normal", "Hard", "SuperHard"]
        
        // データ定義
        let data: [[String]] = [
            ["偶数の出現", "Yes", "No", "No","No"],
            ["3の倍数の出現","Yes","Yes","Yes","No"],
            ["5の倍数の出現","No","No","No","No"],
            ["マイナスのスコア", "No", "No", "Yes","Yes"],
            ["ライフ","7","4","8","5"],
            ["制限時間","60s","60s","90s","120s"],
            ["出現するキューブの最小値","16","27","79","401"],
            ["出現するキューブの最大値","99","123","261","3999"],
            ["同時に出現するキューブの数","1~3","2~3","2~4","3~4"],
            ["素数をタップした時、スコア:","- 素数x2 -120","- 素数x2 -120","- 素数x2 -120","- 素数x2 -1000"],
            ["コンボによるスコアのリセット","No","No","スコアが正の数なら半分","スコアが正の数なら半分"],
            ["重力加速度","-1","-3","-3","-5.2"],
            ["推奨されるプレイヤー","エンジョイ勢","数学好きかも","ソロバンを少々","宇宙からの帰国子女"]
            
        ]
        
        
        
        
        
        // 全体の幅を調整（中央揃えのためマージンを追加）
        let totalTableWidth = view.frame.width * 0.7 // 横幅を80%に縮小
        let leftMargin = (view.frame.width - totalTableWidth) / 2 - 100
        
        // 各列の幅を設定
        let firstColumnWidth = totalTableWidth * 0.4 // 1列目は全体の40%
        let otherColumnWidth = totalTableWidth * 0.2 // 2〜4列目はそれぞれ全体の20%
        let rowHeight: CGFloat = 30 // 行の高さを固定
        
        // ヘッダー行を作成
        for (index, header) in headers.enumerated() {
            let xPosition: CGFloat = leftMargin + (index == 0 ? 0 : firstColumnWidth + CGFloat(index - 1) * otherColumnWidth)
            let columnWidth: CGFloat = index == 0 ? firstColumnWidth : otherColumnWidth
            
            let label = UILabel(frame: CGRect(x: xPosition, y: 0, width: columnWidth, height: rowHeight))
            label.text = header
            label.font = UIFont.boldSystemFont(ofSize: 16)
            label.textAlignment = .center
            label.backgroundColor = .lightGray
            label.textColor = .black
            tableView.addSubview(label)
        }
        
        // データ行を作成
        for (rowIndex, row) in data.enumerated() {
            for (colIndex, value) in row.enumerated() {
                let xPosition: CGFloat = leftMargin + (colIndex == 0 ? 0 : firstColumnWidth + CGFloat(colIndex - 1) * otherColumnWidth)
                let columnWidth: CGFloat = colIndex == 0 ? firstColumnWidth : otherColumnWidth
                
                let label = UILabel(frame: CGRect(
                    x: xPosition,
                    y: CGFloat(rowIndex + 1) * rowHeight,
                    width: columnWidth,
                    height: rowHeight
                ))
                label.text = value
                label.font = UIFont.systemFont(ofSize: 14)
                label.textAlignment = .center
                label.backgroundColor = .white
                label.textColor = .black
                label.layer.borderWidth = 0.5
                label.layer.borderColor = UIColor.gray.cgColor
                tableView.addSubview(label)
            }
        }
        
        // テーブルのサイズを設定
        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: CGFloat((data.count + 1)) * rowHeight)
        return tableView
        
    }

    // 一行を作成するヘルパー関数
    

    
    @objc func backToGameOver() {
        dismiss(animated: true, completion: nil)
    }
}
