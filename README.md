# Cleaning Schedule & Client Management Platform

A multi-user platform designed to streamline scheduling, client management, and communication for cleaning businesses of any size, featuring client-specific templating.

## Overview

This project evolved from addressing scheduling challenges within a family-owned house cleaning business into a scalable platform for multiple users to manage their own cleaning operations. The application provides a centralized system for client management, appointment scheduling, communication, and financial tracking, enhanced by a unique client-specific templating system for recurring tasks and preferences, and a visual representation of confirmed appointment availability.

**Key Features:**

* **Secure User Authentication:** Implemented a robust authentication system allowing multiple cleaning business owners to create secure accounts and manage their respective operations independently. This includes user registration, login, and password management.
* **Independent Business Management:** Each registered user (business owner) has their own isolated database or data space to manage their clients, schedules, and financial information without interfering with other users.
* **Client Management:** Stores detailed client information, including cleaning preferences (e.g., specific tasks, product preferences), preferred payment methods, notes, relationships between clients, and the ability to assign and manage client-specific templates.
* **Client-Specific Templating System:** Allows business owners to create and save reusable templates of cleaning tasks, frequency, and special instructions tailored to individual clients. These templates can be easily applied when scheduling appointments, ensuring consistent service delivery according to client needs.
* **Direct Client Communication:** Integrated texting platform leveraging the Twilio API for direct communication with clients regarding appointments and other inquiries, specific to each business owner's account.
* **Intuitive Calendar Scheduling:** Visual calendar interface for scheduling client appointments with ease for each individual business, with the option to apply client-specific templates to pre-populate appointment details.
*  **Future Calendar Scheduling preview:** Ability to look into the future to see where your recurring appointments land, and ability to schedule those appointments.
* **Bulk Confirmation Messaging:** Ability for each business owner to send confirmation texts to their clients simultaneously with a single click.
* **Client Confirmation/Reschedule:** Clients can easily confirm their appointments by replying with '1' or request a reschedule by replying with '2', with responses tied back to the respective business.
* **Visual Availability Indicator:** Unique visual cues on the calendar to quickly identify weeks or months with open slots versus fully booked schedules based on confirmed appointments for each business.
* **Revenue Tracking:** Provides a money tracker feature for each business owner to project potential revenue based on their scheduled and (if tracked) completed cleaning jobs.

## Technologies Used

* **Frontend:** Flutter
* **Backend:** Dart
* **Authentication:** Firebase Authentication
* **Database:** Firebase
* **API Integration:** Twilio API for SMS communication.
