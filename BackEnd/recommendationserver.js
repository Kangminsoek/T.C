const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const admin = require('firebase-admin');
require('dotenv').config();

// Firebase Admin SDK 초기화
const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: process.env.FIREBASE_DATABASE_URL // Firebase 데이터베이스 URL을 환경 변수로 설정
});

const db = admin.firestore();

const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// Firebase ID 토큰을 검증하는 미들웨어
async function verifyToken(req, res, next) {
  const idToken = req.headers.authorization?.split('Bearer ')[1];
  if (!idToken) {
    return res.status(403).send('Unauthorized');
  }
  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    req.user = decodedToken; // 사용자 정보를 req.user에 저장
    next();
  } catch (error) {
    return res.status(403).send('Unauthorized');
  }
}

// API 엔드포인트

// 추천 코스 정보 가져오기
app.get('/recommendedCourse', verifyToken, async (req, res) => {
  try {
    const courseDoc = await db.collection('courses').doc('recommended').get();
    if (!courseDoc.exists) {
      return res.status(404).send('Recommended course not found');
    }
    res.json(courseDoc.data());
  } catch (error) {
    res.status(500).send('Internal server error');
  }
});

// 추천 장소 목록 가져오기
app.get('/recommendedPlaces', verifyToken, async (req, res) => {
  try {
    const placesSnapshot = await db.collection('places').get();
    const places = placesSnapshot.docs.map(doc => ({
      ...doc.data(),
      userId: doc.data().userId, // UID 포함
    }));
    res.json(places);
  } catch (error) {
    res.status(500).send('Internal server error');
  }
});

// 사용자가 추가한 장소만 가져오기
app.get('/myPlaces', verifyToken, async (req, res) => {
  try {
    const placesSnapshot = await db.collection('places')
      .where('userId', '==', req.user.uid) // UID로 필터링
      .get();
    
    const places = placesSnapshot.docs.map(doc => doc.data());
    res.json(places);
  } catch (error) {
    res.status(500).send('Internal server error');
  }
});

// 장소 추가하기
app.post('/addPlace', verifyToken, async (req, res) => {
  const { title, description, latitude, longitude } = req.body;

  // 필수 필드 확인
  if (!title || !description || typeof latitude !== 'number' || typeof longitude !== 'number') {
    return res.status(400).send('Missing required fields');
  }

  try {
    await db.collection('places').add({
      title,
      description,
      location: new admin.firestore.GeoPoint(latitude, longitude),
      userId: req.user.uid, // 동적으로 사용자의 UID 추가
    });
    res.send('Place added successfully');
  } catch (error) {
    res.status(500).send('Internal server error');
  }
});

// 서버 시작
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
