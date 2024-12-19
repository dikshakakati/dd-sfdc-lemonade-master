import {LightningElement, track} from "lwc";

export default class UserFeedback extends LightningElement {
    @track satisfactionRating;
    @track feedbackText = ""; // To hold the user feedback
    
    // Updates the feedbackText variable when the user enters Feedback Notes
    handleFeedbackChange(event) {
        this.feedbackText = event.target.value; // Storing the user feedback
        
        // Dispatch an event so the parent can update with comments
        const updateCommentsEvent = new CustomEvent("comment", {
            detail: {
                feedbackText: this.feedbackText
            }
        });
        
        this.dispatchEvent(updateCommentsEvent);
    }

    // Called when the Star ratings are clicked to update the satisfactionRating value.
    updateRating(event) {
        if(event && event.target && event.target.value) {
            this.satisfactionRating = parseInt(event.target.value);
        } else {
            this.satisfactionRating = null;
        }
        
        // Dispatch an event so the parent can get the updated rating
        const updateRatingEvent = new CustomEvent("rating", {
            detail: {
                rating: this.satisfactionRating
            }
        });
        
        this.dispatchEvent(updateRatingEvent);
    }
}