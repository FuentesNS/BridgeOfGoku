//
//  Defined.swift
//  BridgeOfGoku
//
//  Created by Samuel Fuentes Navarrete on 31/10/22.
//

import Foundation
import CoreGraphics

let DefinedScreenWidth:CGFloat = 1536
let DefinedScreenHeight:CGFloat = 2048

enum GokuGameSceneChildName : String {
    case PersonageName = "Goku"
    case StickName = "Stick"
    case StackName = "Stack"
    case StackMidName = "Stack_mid"
    case ScoreName = "Score"
    case TipName = "Tip"
    case PerfectName = "Perfect"
    case GameOverLayerName = "Over"
    case RetryButtonName = "Retry"
    case HighScoreName = "Highscore"
}

enum GokuGameSceneActionKey: String {
    case WalkAction = "Walk"
    case StickGrowAudioAction = "Stick_grow_audio"
    case StickGrowAction = "Stick_grow"
    case PersonageScaleAction = "Goku_scale"
}

enum GokuGameSceneEffectAudioName: String {
    case DeadAudioName = "dead.wav"
    case StickGrowAudioName = "stick_grow_loop.wav"
    case StickGrowOverAudioName = "kick.wav"
    case StickFallAudioName = "fall.wav"
    case StickTouchMidAudioName = "touch_mid.wav"
    case VictoryAudioName = "victory.wav"
    case HighScoreAudioName = "highScore.wav"
}

enum GokuGameSceneZposition: CGFloat {
    case BackgroundZposition = 0
    case StackZposition = 30
    case StackMidZposition = 35
    case StickZposition = 40
    case ScoreBackgroundZposition = 50
    case PersonageZposition, ScoreZposition, TipZposition, PerfectZposition = 100
    case EmitterZposition
    case GameOverZposition
}
