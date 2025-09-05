import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="goal-audio"
export default class extends Controller {
  connect() {
    console.log("Goal audio controller connected")
    this.audioElement = document.getElementById("goal-audio")
    
    // Listen for custom goal audio event
    document.addEventListener("goal-audio-trigger", this.playGoalSound.bind(this))
  }

  disconnect() {
    document.removeEventListener("goal-audio-trigger", this.playGoalSound.bind(this))
  }

  playGoalSound() {
    if (this.audioElement) {
      console.log("Playing goal sound!")
      this.audioElement.volume = 0.3 // Set volume to 30%
      this.audioElement.currentTime = 0 // Reset to start
      
      // Handle browser autoplay policies
      const playPromise = this.audioElement.play()
      
      if (playPromise !== undefined) {
        playPromise
          .then(() => {
            console.log("Goal audio played successfully")
          })
          .catch((error) => {
            console.warn("Could not play goal audio:", error)
            // Could show a visual notification instead if audio is blocked
          })
      }
    } else {
      console.error("Goal audio element not found")
    }
  }
}
