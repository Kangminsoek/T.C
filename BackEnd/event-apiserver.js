// index.js 또는 app.js

const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');
require('dotenv').config();

// Mongoose 모델 정의
const eventSchema = new mongoose.Schema({
    title: { type: String, required: true },
    description: { type: String, required: true },
    imagePath: { type: String, required: true },
    date: { type: String, required: true }, // 날짜 형식 확인 필요
});

const Event = mongoose.model('Event', eventSchema);

const app = express();
const PORT = process.env.PORT || 5000;

// 미들웨어 설정
app.use(cors());
app.use(bodyParser.json());

// MongoDB 연결
mongoose.connect(process.env.MONGODB_URI, {
    serverSelectionTimeoutMS: 30000 // 30초 타임아웃 설정
})
.then(() => console.log('MongoDB Connected'))
.catch(err => {
    console.error('MongoDB connection error:', err);
    process.exit(1); // 연결 실패 시 프로세스 종료
});

// 행사 정보 API

// 모든 행사 가져오기
app.get('/api/events', async (req, res) => {
    try {
        const events = await Event.find();
        res.json(events);
    } catch (error) {
        console.error('Error fetching events:', error);
        res.status(500).json({ message: '서버 오류' });
    }
});

// 행사 추가
app.post('/api/events', async (req, res) => {
    const { title, description, imagePath, date } = req.body;

    if (!title || !description || !imagePath || !date) {
        return res.status(400).json({ message: '모든 필드를 입력해야 합니다.' });
    }

    const newEvent = new Event({
        title,
        description,
        imagePath,
        date,
    });

    try {
        const savedEvent = await newEvent.save();
        res.status(201).json(savedEvent);
    } catch (error) {
        console.error('Error saving event:', error);
        res.status(400).json({ message: '행사 추가 실패' });
    }
});

// 행사 수정
app.put('/api/events/:id', async (req, res) => {
    const { id } = req.params;
    const { title, description, imagePath, date } = req.body;

    console.log('Request body:', req.body); // 요청 본문 출력

    if (!title || !description || !imagePath || !date) {
        return res.status(400).json({ message: '모든 필드를 입력해야 합니다.' });
    }

    try {
        const updatedEvent = await Event.findByIdAndUpdate(id, req.body, { new: true });
        if (!updatedEvent) {
            return res.status(404).json({ message: '행사를 찾을 수 없습니다.' });
        }
        res.json(updatedEvent);
    } catch (error) {
        console.error('Error updating event:', error);
        res.status(400).json({ message: '행사 수정 실패' });
    }
});

// 행사 삭제
app.delete('/api/events/:id', async (req, res) => {
    const { id } = req.params;

    try {
        const deletedEvent = await Event.findByIdAndDelete(id);
        if (!deletedEvent) {
            return res.status(404).json({ message: '행사를 찾을 수 없습니다.' });
        }
        res.status(204).send();
    } catch (error) {
        console.error('Error deleting event:', error);
        res.status(500).json({ message: '행사 삭제 실패' });
    }
});

// 서버 시작
app.listen(PORT, () => {
    console.log(`서버가 포트 ${PORT}에서 실행 중입니다.`);
});
