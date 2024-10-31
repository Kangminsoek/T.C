const express = require('express');
const admin = require('firebase-admin');
const bodyParser = require('body-parser');
const cors = require('cors');
const fetch = require('node-fetch');  // node-fetch 추가
require('dotenv').config();

// Firebase Admin SDK 초기화
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const app = express();

// 미들웨어 설정
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// 회원가입 엔드포인트
app.post('/signup', async (req, res) => {
  console.log(req.body); // 요청된 데이터 출력
  const { email, password, name } = req.body;

  // 입력 데이터 검증
  if (!email || !password || !name) {
    return res.status(400).json({ message: '모든 필드를 입력해주세요.' });
  }

  try {
    // Firebase Authentication에 사용자 생성
    const userRecord = await admin.auth().createUser({
      email,
      password,
      displayName: name,
    });

    // Firestore에 사용자 추가 (필요에 따라)
    await admin.firestore().collection('users').doc(userRecord.uid).set({
      email,
      name,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return res.status(201).json({
      message: '회원가입이 성공적으로 완료되었습니다.',
      user: {
        uid: userRecord.uid,
        email: userRecord.email,
        name: userRecord.displayName,
      },
    });
  } catch (error) {
    // 에러 코드에 따른 응답 처리
    let errorMessage = '회원가입 중 오류가 발생했습니다.';
    if (error.code === 'auth/email-already-exists') {
      errorMessage = '이미 사용 중인 이메일입니다.';
    } else if (error.code === 'auth/invalid-email') {
      errorMessage = '유효하지 않은 이메일 형식입니다.';
    } else if (error.code === 'auth/weak-password') {
      errorMessage = '비밀번호는 6자 이상이어야 합니다.';
    }
    return res.status(400).json({ message: errorMessage, error: error.message });
  }
});

// 새로운 POST 요청을 보내는 엔드포인트 추가
app.post('/external-post', async (req, res) => {
  try {
    // fetch를 사용하여 외부 서버에 POST 요청 전송
    const response = await fetch('http://localhost:3000/', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ key: 'value' })
    });

    const data = await response.text();
    console.log(data);

    return res.status(200).json({
      message: '외부 POST 요청이 성공적으로 완료되었습니다.',
      data
    });
  } catch (error) {
    console.error('fetch 요청 중 오류 발생:', error);
    return res.status(500).json({
      message: '외부 서버로의 POST 요청 중 오류가 발생했습니다.',
      error: error.message
    });
  }
});

// 서버 시작
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`서버가 포트 ${PORT}에서 실행 중입니다.`);
});
