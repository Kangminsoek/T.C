const express = require('express');
const axios = require('axios'); 
const uuidAPIKey = require('uuid-apikey');
const psql = require('./psql'); 

const app = express();
const router = express.Router();


app.use(express.json());


const server = app.listen(3001, () => {
    console.log('Start Server : localhost:3001');
});


console.log(uuidAPIKey.create());

const key = {
    apiKey: 'W8XZ54H-DWS45BD-PKGWRW1-SG1GM2D',
    uuid: 'e23bf292-6f32-42ad-b4e1-cc70cc030a09'
};


app.get('/api/users/:apikey/:type', async (req, res) => {
    const { apikey, type } = req.params;

   
    if (!uuidAPIKey.isAPIKey(apikey) || !uuidAPIKey.check(apikey, key.uuid)) {
        return res.status(401).send('apikey is not valid.');
    }

    try {
        let googleApiUrl;

      
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

// API 엔드포인트 - 데이트 코스 관련 기능

// 데이트 코스 목록 가져오기 (GET)
router.get('/courses', async (req, res) => {
    try {
        const result = await psql.query('SELECT * FROM courses');
        res.json(result.rows);
    } catch (err) {
        console.error(err);
        res.status(500).send('서버 오류');
    }
});

// 새로운 데이트 코스 추가 (POST)
router.post('/courses', async (req, res) => {
    const { name, description, location } = req.body;

    if (!name || !description || !location) {
        return res.status(400).send('필수 항목이 누락되었습니다.');
    }

    try {
        const result = await psql.query(
            'INSERT INTO courses (name, description, location) VALUES ($1, $2, $3) RETURNING *',
            [name, description, location]
        );
        res.status(201).json(result.rows[0]);
    } catch (err) {
        console.error(err);
        res.status(500).send('서버 오류');
    }
});

// Router 연결
app.use('/api', router);
