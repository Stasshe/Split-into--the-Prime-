import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    private var audioPlayer: AVAudioPlayer?
    private var fadeTimer: Timer?
    private var isMuted: Bool = false
    private var tapPlayer: AVAudioPlayer?
    private init() {}
    
    func playSound(fileName: String, fileType: String = "mp3", loop: Bool = true, fadeDuration: TimeInterval = 2.0) {
        configureAudioSession()
        stopSound() // 既存の音楽を停止
        
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
            print("Sound file \(fileName).\(fileType) not found.")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = loop ? -1 : 0
            audioPlayer?.volume = 0.0 // フェードインのため、初期音量を0に
            audioPlayer?.play()
            fadeIn(duration: fadeDuration) // フェードインを開始
        } catch {
            print("Error playing sound: \(error)")
        }
    }
    func configureAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            try audioSession.setActive(true)
            stopSound()
        } catch {
            print("Failed to configure audio session: \(error.localizedDescription)")
            stopSound()
        }
    }

    func playTapSound(fileName: String = "tapp", fileType: String = "mp3") {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileType) else {
            print("Tap sound file \(fileName).\(fileType) not found.")
            return
        }
        do {
            tapPlayer = try AVAudioPlayer(contentsOf: url)
            tapPlayer?.volume = isMuted ? 0.0 : 1.0
            tapPlayer?.play()
        } catch {
            print("Error playing tap sound: \(error)")
        }
    }

    func stopSound(fadeDuration: TimeInterval = 2.0) {
        guard let player = audioPlayer else { return }
        fadeOut(duration: fadeDuration) {
            player.stop()
            self.audioPlayer = nil
        }
    }
    
    func toggleMute() {
        isMuted.toggle()
        audioPlayer?.volume = isMuted ? 0.0 : 1.0
    }
    
    func isAudioMuted() -> Bool {
        return isMuted
    }
    
    // フェードイン
    private func fadeIn(duration: TimeInterval) {
        fadeTimer?.invalidate() // 既存のタイマーを停止
        audioPlayer?.volume = 0.0 // 確実に音量を0に
        let interval = 0.1
        let steps = Int(duration / interval)
        var currentStep = 0
        
        fadeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self = self, let player = self.audioPlayer else {
                timer.invalidate()
                return
            }
            currentStep += 1
            player.volume = min(1.0, player.volume + Float(1.0 / Double(steps))) // 音量を増加
            if currentStep >= steps {
                timer.invalidate()
            }
        }
    }
    
    // フェードアウト
    private func fadeOut(duration: TimeInterval, completion: @escaping () -> Void) {
        fadeTimer?.invalidate() // 既存のタイマーを停止
        let interval = 0.1
        let steps = Int(duration / interval / 2)
        var currentStep = 0
        
        fadeTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] timer in
            guard let self = self, let player = self.audioPlayer else {
                timer.invalidate()
                return
            }
            currentStep += 1
            player.volume = max(0.0, player.volume - Float(1.0 / Double(steps))) // 音量を減少
            if currentStep >= steps {
                timer.invalidate()
                player.volume = 0.0 // 音量を完全に0に
                completion()
            }
        }
    }
}
