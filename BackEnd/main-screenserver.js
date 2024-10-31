const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const port = 3000;

// Middleware
app.use(bodyParser.json());
app.use(cors());

// Mock data (In a real application, you would query a database)
const mockData = {
  'courses': [
    { id: 1, name: 'AI 데이터 코스 추천', description: 'AI 데이터 분석을 위한 코스' },
    { id: 2, name: '카테고리 별 코스 추천', description: '다양한 카테고리의 코스 추천' },
    { id: 3, name: 'MBTI 별 코스 추천', description: 'MBTI 성격 유형에 맞는 코스' },
    { id: 4, name: '행사 정보', description: '현재 진행 중인 행사 정보' }
  ]
};

// Routes
app.post('/login', (req, res) => {
  const { username, password } = req.body;

  // Dummy authentication (Replace with real authentication logic)
  if (username === 'user' && password === 'password') {
    res.json({ token: 'dummy-token' });
  } else {
    res.status(401).json({ error: 'Invalid credentials' });
  }
});

app.get('/aiDateCourse', (req, res) => {
  // Example response (Replace with real data)
  res.json(mockData.courses.find(course => course.name === 'AI 데이터 코스 추천'));
});

app.get('/category', (req, res) => {
  // Example response (Replace with real data)
  res.json(mockData.courses.find(course => course.name === '카테고리 별 코스 추천'));
});

app.get('/mbti', (req, res) => {
  // Example response (Replace with real data)
  res.json(mockData.courses.find(course => course.name === 'MBTI 별 코스 추천'));
});

app.get('/event', (req, res) => {
  // Example response (Replace with real data)
  res.json(mockData.courses.find(course => course.name === '행사 정보'));
});

app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
