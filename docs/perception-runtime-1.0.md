# PerceptionRuntime 1.0

PerceptionRuntime is the parent runtime for modelling what happens when any signal is perceived. SpeechRuntime remains as one modality adapter inside this wider runtime.

## Runtime chain

```text
SignalEvent -> SignalBundle -> PerceptionGenome -> ListenerGenome -> SpeciesRuntime -> MeaningGraph -> PropagationEngine -> WeatherEngine -> HundredRoom -> ActionGraph -> RealityLedger
```

## Principle
Speech is one sense. The system must model speech, text, sight, sound, smell, touch, taste, gesture, movement, silence, absence, behaviour, biometrics, environmental signals, system logs, financial signals and organisational signals through one shared runtime.

## Core objects

- SignalEvent: one detected input from a human, AI, system, robot, animal, environment, family context or future-state model.
- SignalBundle: multiple SignalEvents interpreted together.
- PerceptionGenome: common primitive layer across all modalities.
- ListenerGenome: how different listeners perceive the same event.
- SpeciesRuntime: translation across humans, AI, machines, robots, children, animals, regulators and future selves.
- MeaningGraph: interpreted meaning variants and conflicts.
- PropagationEngine: how meaning spreads and mutates.
- WeatherEngine: Speedo telemetry for confusion, trust, fear, drift and readiness.
- HundredRoom: the visible chamber of 100 perceived interpretations.
- ActionGraph: routable next-best actions.
- RealityLedger: evidence, receipts, telemetry, gaps and state.

## Reality state
PARTIAL until runtime execution, telemetry and bridge receipts prove the system.
