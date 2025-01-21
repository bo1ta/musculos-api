//
//  workoutChallenges.swift
//  Musculos
//
//  Created by Solomon Alexandru on 19.01.2025.
//

[
  {
    "title": "Rocky Balboa Workout",
      "description": "An intense workout inspired by Rocky Balboa's training routine.",
      "level": "Advanced",
      "durationInDays": 15,
      "restDayInterval": 5,
      "dailyWorkouts": [
        {
          "day": 1,
            "isRestDay": false,
            "exercises": [
              { "name": "Push-ups", "numberOfReps": 50 },
              { "name": "Sit-ups", "numberOfReps": 100 },
              { "name": "Jump Rope", "duration": 10, "measurement": "minutes" },
            ]
        },
        {
          "day": 5,
            "isRestDay": true,
            "exercises": []
        },
        {
          "day": 6,
            "isRestDay": false,
            "exercises": [
              { "name": "Shadow Boxing", "duration": 15, "measurement": "minutes" },
              { "name": "Pull-ups", "numberOfReps": 20 },
            ]
        },
      ]
  },
]
