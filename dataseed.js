// dataSeed.js
const mongoose = require('mongoose');
const Course = require('./models/Course');

async function seedDatabase() {
    await mongoose.connect('mongodb://localhost:27017/date_courses', {
        useNewUrlParser: true,
        useUnifiedTopology: true,
    });

    const courses = [
        { name: 'Romantic Dinner', location: 'Downtown', preferences: ['dinner', 'romantic'], budget: 100 },
        { name: 'Outdoor Picnic', location: 'Park', preferences: ['outdoor', 'relax'], budget: 50 },
        { name: 'Movie Night', location: 'City Center', preferences: ['movie', 'indoor'], budget: 30 },
    ];

    await Course.insertMany(courses);
    console.log('Database seeded!');
    mongoose.connection.close();
}

seedDatabase();
