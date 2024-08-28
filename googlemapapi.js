const express = require('express');
const mongoose = require('mongoose');
const { createClient } = require('redis');
const { Client } = require('@googlemaps/google-maps-services-js');
require('dotenv').config(); // 환경 변수 로드

const app = express();
const redisClient = createClient();
const googleMapsClient = new Client({});
const PORT = process.env.PORT || 5000; // 포트 설정

// 미들웨어 설정
app.use(express.json()); // JSON 파싱

// MongoDB 연결
mongoose.connect('mongodb://localhost:27017/date_courses', {
    useNewUrlParser: true,
    useUnifiedTopology: true,
});

// Redis 클라이언트 연결
(async () => {
    try {
        await redisClient.connect(); // Redis 클라이언트 연결
        console.log('Connected to Redis');
    } catch (error) {
        console.error('Redis connection error:', error);
    }
})();

// 구글 맵 API 사용 예시
app.get('/api/geocode', async (req, res) => {
    const { address } = req.query; // 쿼리에서 주소 받기

    try {
        const response = await googleMapsClient.geocode({
            params: {
                address: address,
                key: process.env.GOOGLE_MAPS_API_KEY, // 환경 변수에서 API 키 가져오기
            },
            timeout: 1000, // 타임아웃
        });
        res.json(response.data); // 결과 반환
    } catch (error) {
        console.error('Error fetching geocode:', error);
        res.status(500).send('Error fetching geocode');
    }
});

// 서버 시작
app.listen(PORT, () => {
    console.log(`서버가 포트 ${PORT}에서 실행 중입니다.`);
});
