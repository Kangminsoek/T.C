const express = require('express');
const mongoose = require('mongoose');
const { createClient } = require('redis');
const apiRoutes = require('./api'); // apiRoutes 추가

const app = express();
const redisClient = createClient();
const PORT = process.env.PORT || 5000; // 포트 설정

// 미들웨어 설정
app.use(express.json()); // JSON 파싱

// MongoDB 연결
mongoose.connect('mongodb://localhost:27017/date_courses', {
    // useNewUrlParser와 useUnifiedTopology 제거 (최신 Mongoose 버전에서는 기본값)
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

// API 경로 설정
app.use('/api', apiRoutes); // '/api' 경로로 API 라우트 설정

// 서버 시작
app.listen(PORT, () => {
    console.log(`서버가 포트 ${PORT}에서 실행 중입니다.`);
});
