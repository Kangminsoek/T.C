require('dotenv').config();
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { Pool } = require('pg');
const { body, validationResult } = require('express-validator');

const app = express();
const PORT = 8080; // 포트 번호를 8080으로 설정

// PostgreSQL 연결 설정
const pool = new Pool({
  user: 'postgres',       // 데이터베이스 사용자명
  host: 'localhost',      // 데이터베이스 호스트명
  database: 'cppick',     // 데이터베이스 이름
  password: '1234',       // 데이터베이스 비밀번호
  port: 5432,             // PostgreSQL 기본 포트
});

app.use(cors());
app.use(bodyParser.json());

// 정적 카테고리 데이터
const staticCategories = [
  { id: 1, title: '오늘은 야외로~!', imagePath: 'assets/images/outdoor.png' },
  { id: 2, title: '오늘은 실내로~!', imagePath: 'assets/images/indoor.png' },
  { id: 3, title: '교양 데이트', imagePath: 'assets/images/culture.png' },
  { id: 4, title: '맛집 탐방 어때?', imagePath: 'assets/images/food.png' },
  { id: 5, title: '쇼핑/시장', imagePath: 'assets/images/shopping.png' },
  { id: 6, title: '6월 축제/이벤트', imagePath: 'assets/images/festival.png' },
  { id: 7, title: '너의 취미가 뭐니?', imagePath: 'assets/images/hobby.png' },
  { id: 8, title: '힐링 데이트 어때?', imagePath: 'assets/images/healing.png' },
];

// 기본 경로에 대한 GET 요청 처리
app.get('/', (req, res) => {
  res.send('Welcome to the API!');
});
// URL: http://localhost:8080/

// 정적 카테고리 목록 API
app.get('/api/categories-static', (req, res) => {
  res.json(staticCategories);
});
// URL: http://localhost:8080/api/categories-static

// 카테고리 라우터 설정
const categoriesRouter = express.Router();

// 카테고리 생성
categoriesRouter.post(
  '/',
  [
    body('name').notEmpty(),
    body('description').optional(),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { name, description } = req.body;
    try {
      const result = await pool.query(
        `INSERT INTO categories (name, description)
         VALUES ($1, $2) RETURNING *`,
        [name, description]
      );
      res.status(201).json(result.rows[0]);
    } catch (error) {
      console.error('Error creating category:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }
);
// URL: http://localhost:8080/api/categories (POST 요청, body: { "name": "새 카테고리", "description": "카테고리 설명" })

// 카테고리 조회
categoriesRouter.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM categories');
    res.json(result.rows);
  } catch (error) {
    console.error('Error fetching categories:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});
// URL: http://localhost:8080/api/categories (GET 요청)

// 카테고리 업데이트
categoriesRouter.put(
  '/:id',
  [
    body('name').notEmpty(),
    body('description').optional(),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const categoryId = req.params.id;
    const { name, description } = req.body;
    try {
      const result = await pool.query(
        `UPDATE categories
         SET name = $1, description = $2
         WHERE category_id = $3 RETURNING *`,
        [name, description, categoryId]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({ error: 'Category not found' });
      }

      res.json(result.rows[0]);
    } catch (error) {
      console.error('Error updating category:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }
);
// URL: http://localhost:8080/api/categories/:id (PUT 요청, body: { "name": "업데이트된 카테고리", "description": "업데이트된 설명" })

// 카테고리 삭제
categoriesRouter.delete('/:id', async (req, res) => {
  const categoryId = req.params.id;
  try {
    const result = await pool.query(
      `DELETE FROM categories
       WHERE category_id = $1 RETURNING *`,
      [categoryId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Category not found' });
    }

    res.json({ message: 'Category deleted successfully' });
  } catch (error) {
    console.error('Error deleting category:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});
// URL: http://localhost:8080/api/categories/:id (DELETE 요청)

// 카테고리 라우터를 '/api/categories' 경로에 연결
app.use('/api/categories', categoriesRouter);

// 서버 시작
app.listen(PORT, '0.0.0.0', () => { // 0.0.0.0으로 설정하여 모든 IP에서 접근 가능
  console.log(`서버가 http://localhost:${PORT}에서 실행 중입니다.`);
});
