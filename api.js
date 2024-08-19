const express = require('express');
const axios = require('axios'); // Axios를 사용하여 HTTP 요청을 보냅니다.
const uuidAPIKey = require('uuid-apikey');

const app = express();
const server = app.listen(3001, () => {
    console.log('Start Server : localhost:3001');
});

// API 키 생성 예시 (테스트용)
console.log(uuidAPIKey.create());

const key = {
    apiKey: 'W8XZ54H-DWS45BD-PKGWRW1-SG1GM2D',
    uuid: 'e23bf292-6f32-42ad-b4e1-cc70cc030a09'
};

// API 엔드포인트
app.get('/api/users/:apikey/:type', async (req, res) => {
    const { apikey, type } = req.params;

    // API 키 유효성 검사
    if (!uuidAPIKey.isAPIKey(apikey) || !uuidAPIKey.check(apikey, key.uuid)) {
        return res.status(401).send('apikey is not valid.');
    }

    try {
        let googleApiUrl;

        // 요청한 type에 따라 구글 API의 엔드포인트 결정
        if (type === 'A') {
            googleApiUrl = `https://example.com/api/A?key=${key.apiKey}`; // 실제 구글 API URL로 변경
        } else if (type === 'B') {
            googleApiUrl = `https://example.com/api/B?key=${key.apiKey}`; // 실제 구글 API URL로 변경
        } else {
            return res.status(400).send('Type is not correct.');
        }

        // 구글 API 호출
        const response = await axios.get(googleApiUrl);
        
        // 응답 데이터 반환
        res.json(response.data);
    } catch (error) {
        console.error(error);
        res.status(500).send('Error fetching data from Google API.');
    }
});
