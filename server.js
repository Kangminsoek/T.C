// server.js
const express = require('express');
const mongoose = require('mongoose');
const { createClient } = require('redis'); // createClient로 수정
const Course = require('./models/course');

const app = express();
const redisClient = createClient(); // createClient()로 변경
const PORT = 3001;

app.use(express.json());

// MongoDB 연결
mongoose.connect('mongodb://localhost:27017/date_courses', {
    // useNewUrlParser와 useUnifiedTopology 제거
});

// Redis 클라이언트 연결
(async () => {
    try {
        await redisClient.connect(); // Redis 클라이언트 연결
    } catch (error) {
        console.error('Redis connection error:', error);
    }
})();

// 사용자 맞춤 추천 API
app.post('/api/recommend', async (req, res) => {
    const { location, preferences, budget } = req.body;

    // Redis 캐시에서 결과 검색
    const cacheKey = `${location}:${preferences.join(',')}:${budget}`;
    redisClient.get(cacheKey, async (err, cachedData) => {
        if (err) throw err;

        if (cachedData) {
            return res.json(JSON.parse(cachedData));
        } else {
            // DB에서 추천 코스 검색
            try {
                const courses = await Course.find({
                    location,
                    preferences: { $in: preferences },
                    budget: { $lte: budget },
                });

                // 결과를 Redis에 캐시
                redisClient.setEx(cacheKey, 3600, JSON.stringify(courses)); // 1시간 캐시

                return res.json(courses);
            } catch (error) {
                console.error(error);
                return res.status(500).send('Error fetching courses.');
            }
        }
    });
});

// 서버 시작
app.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
