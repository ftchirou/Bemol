///
/// MIDINotePlayer.swift
/// Bemol
///
/// Copyright 2025 Faiçal Tchirou
///
/// Bemol is free software: you can redistribute it and/or modify it under the terms of
/// the GNU General Public License as published by the Free Software Foundation, either version 3
/// of the License, or (at your option) any later version.
///
/// Bemol is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
/// without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
/// See the GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License along with Foobar.
/// If not, see <https://www.gnu.org/licenses/>.
///

import AVFoundation
import Foundation

actor MIDINotePlayer: NotePlayer {
  enum Error: Swift.Error {
    case couldNotLoadSoundFont
  }

  private let bpm: Float64 = 110.0
  private let beatPrecision = AVMusicTimeStamp(0.05)
  private let noteDurationInBeats = AVMusicTimeStamp(1.0)
  private let noteVelocity: UInt32 = 76

  private let audioEngine: AVAudioEngine
  private let sampler: AVAudioUnitSampler
  private let sequencer: AVAudioSequencer
  private var chordTrack: AVMusicTrack?
  private var noteTrack: AVMusicTrack?

  private let clock = ContinuousClock()
  private var startTime: ContinuousClock.Instant = .now
  private var chordProgressions: [Cadence: [[AVMIDINoteEvent]]] = [:]

  init() {
    audioEngine = AVAudioEngine()
    sampler = AVAudioUnitSampler()
    audioEngine.attach(sampler)
    audioEngine.connect(sampler, to: audioEngine.mainMixerNode, format: nil)
    sequencer = AVAudioSequencer(audioEngine: audioEngine)
  }

  func prepareToPlay() async throws {
    try loadSoundFont()
    try AVAudioSession.sharedInstance().setCategory(.playback, options: .duckOthers)

    chordTrack = sequencer.createAndAppendTrack()
    noteTrack = sequencer.createAndAppendTrack()
    sequencer.tempoTrack.addEvent(AVExtendedTempoEvent(tempo: bpm), at: 0.0)

    try audioEngine.start()
    try sequencer.start()
  }

  func playNote(_ note: Note) async throws {
    let note = makeMIDINoteEvent(note)
    let beat = sequencer.currentPositionInBeats + beatPrecision
    noteTrack?.addEvent(note, at: beat)

    try await Task.sleep(for: .seconds(sequencer.seconds(forBeats: 0.75)), clock: clock)
  }
  
  func playCadence(_ cadence: Cadence) async throws {
    try await Task.sleep(for: .seconds(0.25), clock: clock)

    let progression = makeChordProgression(cadence)
    let beat = sequencer.currentPositionInBeats + beatPrecision

    chordTrack?.isMuted = true

    for (i, chord) in progression.enumerated() {
      for j in 0..<chord.count {
        chordTrack?.addEvent(chord[j], at: AVMusicTimeStamp(i) + beat)
      }
    }

    chordTrack?.isMuted = false
    sequencer.currentPositionInBeats = beat

    try await Task.sleep(for: .seconds(sequencer.seconds(forBeats: 4) + 0.25), clock: clock)
  }

  // MARK: - Private Helpers

  private func makeMIDINoteEvent(_ note: Note) -> AVMIDINoteEvent {
    let key = if note.octave == 0 {
      keyNumber(for: note.name, octave: 3)
    } else if note.octave == 1 {
      keyNumber(for: note.name, octave: 4)
    } else {
      keyNumber(for: note.name, octave: 5)
    }

    return AVMIDINoteEvent(
      channel: 0,
      key: key,
      velocity: noteVelocity,
      duration: 1.0
    )
  }

  private func makeChordProgression(_ cadence: Cadence) -> [[AVMIDINoteEvent]] {
    if let progression = chordProgressions[cadence] {
      return progression
    }

    var progression: [[AVMIDINoteEvent]] = []
    let voices = cadence.voices

    for movement in cadence.movement {
      var chord: [AVMIDINoteEvent] = []

      for (j, value) in movement.enumerated() {
        chord.append(
          AVMIDINoteEvent(
            channel: 0,
            key: UInt32(Int(keyNumber(for: voices[j], octave: 4)) + value),
            velocity: noteVelocity,
            duration: noteDurationInBeats
          )
        )
      }

      progression.append(chord)
    }

    chordProgressions[cadence] = progression

    return progression
  }

  private func loadSoundFont() throws {
    if let url = Bundle.main.url(forResource: "sound_font", withExtension: "sf2") {
      try sampler.loadSoundBankInstrument(
        at: url,
        program: 0,
        bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
        bankLSB: UInt8(kAUSampler_DefaultBankLSB)
      )
    }
  }

  private func keyNumber(for note: NoteName, octave: UInt8) -> UInt32 {
    UInt32(note.rawValue + (octave * 12))
  }
}
