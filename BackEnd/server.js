// server.js
require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser'); // 필요한 경우
const { Pool, Client } = require('pg'); // PostgreSQL 연결
const cors = require('cors'); // CORS 설정
const mongoose = require('mongoose');
const axios = require('axios');

const app = express();
app.use(bodyParser.json());
app.use(cors()); // CORS를 허용

// PostgreSQL 연결 설정
const client = new Client({
    user: 'postgres', // PostgreSQL 사용자명
    host: 'localhost',
    database: 'cppick',
    password: '1234',
    port: 5432,
});

client.connect()
    .then(() => console.log('Connected to PostgreSQL'))
    .catch(err => console.error('Connection error', err.stack));

// MongoDB 연결
mongoose.connect(process.env.MONGODB_URI, { useNewUrlParser: true, useUnifiedTopology: true })
    .then(() => console.log('MongoDB Connected'))
    .catch(err => console.log(err));

// 위치 정보 스키마
const LocationSchema = new mongoose.Schema({
    name: String,
    latitude: Number,
    longitude: Number,
    createdAt: { type: Date, default: Date.now }
});

const Location = mongoose.model('Location', LocationSchema);

// 위치 저장 엔드포인트
app.post('/api/locations', async (req, res) => {
    const { name, latitude, longitude } = req.body;

    const newLocation = new Location({ name, latitude, longitude });
    
    try {
        await newLocation.save();
        res.status(201).json(newLocation);
    } catch (error) {
        res.status(500).json({ message: 'Error saving location', error });
    }
});

// 코스 데이터를 저장하는 API 엔드포인트
app.post('/api/course', async (req, res) => {
    const { selectedAddress, selectedOptions, selectedImages, distanceValue, budgetValue } = req.body;

    try {
        const query = `
            INSERT INTO date_courses (address, options, images, distance, budget)
            VALUES ($1, $2, $3, $4, $5)
            RETURNING *;
        `;
        const result = await client.query(query, [selectedAddress, selectedOptions, selectedImages, distanceValue, budgetValue]);
        res.status(201).json(result.rows[0]);
    } catch (error) {
        console.error('Error inserting course data:', error);
        res.status(500).send('Server error');
    }
});

// 사용자 삽입 엔드포인트
app.post('/api/users', async (req, res) => {
    const { email, username, googleId, kakaoId, naverId, passwordHash } = req.body;

    const query = `
        INSERT INTO users (email, username, google_id, kakao_id, naver_id, password_hash)
        VALUES ($1, $2, $3, $4, $5, $6) RETURNING *;
    `;
    const values = [email, username, googleId, kakaoId, naverId, passwordHash];

    try {
        const result = await client.query(query, values);
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error('Error inserting user:', err.stack);
        res.status(500).json({ message: 'Error inserting user', error: err });
    }
});

// 구글 맵 API를 통한 위치 정보 조회 엔드포인트
app.get('/api/locations/:locationName', async (req, res) => {
    const { locationName } = req.params;

    try {
        const response = await axios.get('https://maps.googleapis.com/maps/api/geocode/json', {
            params: {
                address: locationName,
                key: process.env.GOOGLE_MAPS_API_KEY
            }
        });

        if (response.data.status === 'OK') {
            const locationData = response.data.results[0].geometry.location;
            res.status(200).json({
                name: locationName,
                latitude: locationData.lat,
                longitude: locationData.lng
            });
        } else {
            res.status(404).json({ message: 'Location not found' });
        }
    } catch (error) {
        res.status(500).json({ message: 'Error fetching location data', error });
    }
});

// 서버 실행
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
