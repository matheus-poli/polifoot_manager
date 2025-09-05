// Register custom Turbo Stream action for goal audio
// Using global Turbo object that's already available
Turbo.StreamActions.goal_audio = function() {
  // Dispatch a custom event that our Stimulus controller can listen to
  const goalEvent = new CustomEvent('goal-audio-trigger')
  document.dispatchEvent(goalEvent)
}