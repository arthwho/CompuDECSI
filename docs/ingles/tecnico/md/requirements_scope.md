# Requirements and Scope

This section details the functional and non-functional requirements, deliverables, exclusions, assumptions, and constraints that define the scope of the Computer Science Week Application project.

## Functional Requirements (FR)

Functional requirements describe what the system must do.

### FR-01: Schedule Management and Consultation
- Allow complete schedule viewing by day and time
- Offer filters by activity type (e.g., lecture, workshop, robotics)
- Display activity locations, indicating the room

### FR-02: Check-in System
- Implement on-site check-in through code entry provided by the speaker
- Automatically register user attendance after check-in
- Maintain a history of activities in which the user participated

### FR-03: Personalized Agenda
- Allow users to mark activities of their interest
- Send reminders before the start of a marked activity

### FR-04: Real-time Interaction (Q&A)
- Allow sending questions to speakers during presentations
- Implement a voting system for questions to be accepted or not

### FR-05: Feedback System
- Collect user feedback on lectures and the event in general after completion

## Non-Functional Requirements (NFR)

Non-functional requirements describe how the system should operate and its qualities.

### NFR-01: Usability
The application must have a friendly and responsive interface, adapting to different screen sizes.

## Project Deliverables

- Functional application for the Android platform
- Detailed technical documentation of the system
- End-user manual
- Organizer manual for administrative panel use
- Final report on the application's operation and use during the event

## Scope Exclusions

**What will not be done:**

- Social media integration
- Chat functionality between participants
- Online payment or registration system
- A complete system for generating and delivering digital certificates

## Assumptions and Constraints

### Assumptions

- The event schedule will be provided by the organization and will not undergo major changes
- Wi-Fi connection will be available and stable at event locations
- The development team has basic knowledge of Flutter and agile methodologies

### Constraints

- **Deadline**: The application must be completed and published one week before the event date
- **Budget**: The project operates with a simulated budget and limited resources
- **Human Resources**: The development team is small, composed of approximately 4 to 6 people
