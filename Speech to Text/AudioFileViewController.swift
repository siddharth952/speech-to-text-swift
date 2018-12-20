/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import UIKit
import AVFoundation
import SpeechToTextV1

class AudioFileViewController: UIViewController, AVAudioPlayerDelegate {

    var player: AVAudioPlayer!
    var speechToText: SpeechToText!
    var speechSample: URL!
    var accumulator = SpeechRecognitionResultsAccumulator()
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        speechSample = Bundle.main.url(forResource: "SpeechSample", withExtension: "wav")
        player = try! AVAudioPlayer(contentsOf: speechSample)
        speechToText = SpeechToText(
            apiKey: Credentials.SpeechToTextApiKey
        )
        player.delegate = self
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setTitle("Play Audio File", for: .normal)
    }
    
    @IBAction func didPressPlayButton(_ sender: UIButton) {
        if !player.isPlaying {
            playButton.setTitle("Stop Audio File", for: .normal)
            player.currentTime = 0
            player.play()
        } else {
            playButton.setTitle("Play Audio File", for: .normal)
            player.stop()
        }
    }

    @IBAction func didPressTranscribeButton(_ sender: UIButton) {
        var settings = RecognitionSettings(contentType: "audio/wav")
        settings.interimResults = true
        speechToText.recognize(audio: speechSample, settings: settings) {
            
            
            response, error in
            if let error = error {
                print(error)
            }
            guard let results = response?.result else {
                print("Failed to recognize the audio")
                return
            }
            self.accumulator.add(results: results)
            self.textView.text = self.accumulator.bestTranscript
 
        }
    }
}
