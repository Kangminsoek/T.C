const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(express.static(path.join(__dirname, 'public'))); // public 폴더를 정적 파일로 제공

// MBTI 추천 데이터
const recommendations = {
    E: ['활동적인 모임', '팀 스포츠', '사회적 이벤트'],
    I: ['독서', '명상', '혼자 하는 취미'],
    S: ['실용적인 워크숍', 'DIY 프로젝트', '자연 탐방'],
    N: ['창의적인 글쓰기', '예술 전시회', '철학적 토론'],
    F: ['자원봉사', '감정적 지원 그룹', '예술과 감정'],
    T: ['논리적 토론', '과학적 연구', '전문적인 강의'],
    P: ['즉흥적인 여행', '모험 스포츠', '유연한 일정의 활동'],
    J: ['계획적인 여행', '목표 설정 세미나', '조직적인 활동'],
};

// MBTI 유형에 따른 추천 코스 API
app.get('/recommendations/:mbti', (req, res) => {
    const mbti = req.params.mbti.toUpperCase();
    if (recommendations[mbti]) {
        res.json(recommendations[mbti]);
    } else {
        res.status(404).json({ message: '추천 코스를 찾을 수 없습니다.' });
    }
});

// HTML 페이지 제공
app.get('/', (req, res) => {
    res.send(`
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MBTI 추천 코스</title>
    <script>
        async function getRecommendations() {
            const mbti = document.getElementById('mbtiInput').value.toUpperCase();
            const response = await fetch(\`/recommendations/\${mbti}\`);
            const resultDiv = document.getElementById('result');

            if (response.ok) {
                const recommendations = await response.json();
                resultDiv.innerHTML = \`<h3>\${mbti} 추천 코스:</h3><ul>\${recommendations.map(item => \`<li>\${item}</li>\`).join('')}</ul>\`;
            } else {
                resultDiv.innerHTML = \`<h3>\${mbti}에 대한 추천 코스를 찾을 수 없습니다.</h3>\`;
            }
        }
    </script>
</head>
<body>
    <h1>MBTI 추천 코스</h1>
    <input type="text" id="mbtiInput" placeholder="MBTI 입력 (예: ENFP)" />
    <button onclick="getRecommendations()">추천 코스 가져오기</button>
    <div id="result"></div>
</body>
</html>
    `);
});

app.listen(PORT, () => {
    console.log(`서버가 http://localhost:${PORT}에서 실행 중입니다.`);
});
