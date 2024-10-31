const express = require('express');
const { Sequelize, DataTypes, Op } = require('sequelize');
const { body, validationResult } = require('express-validator');
const cors = require('cors');

// Express 애플리케이션 설정
const app = express();
const port = 3000;

// 미들웨어 설정
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cors()); // CORS를 허용합니다.

// SQLite 데이터베이스 설정
const sequelize = new Sequelize({
  dialect: 'sqlite',
  storage: './database.sqlite'
});

// DateCourse 모델 정의
const DateCourse = sequelize.define('DateCourse', {
  title: {
    type: DataTypes.STRING,
    allowNull: false
  },
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  start_time: {
    type: DataTypes.DATE,
    allowNull: false
  },
  end_time: {
    type: DataTypes.DATE,
    allowNull: false
  },
  optionType: {
    type: DataTypes.STRING,
    allowNull: true
  },
  address: {
    type: DataTypes.STRING,
    allowNull: true
  },
  latitude: {
    type: DataTypes.FLOAT,
    allowNull: true
  },
  longitude: {
    type: DataTypes.FLOAT,
    allowNull: true
  },
  distance: {
    type: DataTypes.FLOAT,
    allowNull: true
  },
  budget: {
    type: DataTypes.INTEGER,
    allowNull: true
  }
}, {
  tableName: 'DateCourses'
});

// 메모리에서 사용할 코스 리스트
let courses = [];

// 데이 스케줄 생성 (메모리)
app.post('/api/date_courses_memory', (req, res) => {
  const { title, user_id, start_time, end_time } = req.body;
  const newCourse = { id: courses.length + 1, title, user_id, start_time, end_time };
  courses.push(newCourse);
  res.status(201).json(newCourse);
});

// 데이 스케줄 조회 (메모리)
app.get('/api/date_courses_memory/:userId', (req, res) => {
  const userId = req.params.userId;
  const userCourses = courses.filter(course => course.user_id == userId);
  res.json(userCourses);
});

// 데이 스케줄 삭제 (메모리)
app.delete('/api/date_courses_memory/:courseId', (req, res) => {
  const courseId = req.params.courseId;
  courses = courses.filter(course => course.id != courseId);
  res.status(204).send();
});

// 데이 스케줄 생성 (DB)
app.post(
  '/api/date_courses',
  [
    body('title').notEmpty().withMessage('Title is required'),
    body('user_id').isInt().withMessage('User ID must be an integer'),
    body('start_time').isISO8601().withMessage('Start time must be a valid date'),
    body('end_time').isISO8601().withMessage('End time must be a valid date')
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }

    const { title, user_id, start_time, end_time } = req.body;

    try {
      const dateCourse = await DateCourse.create({ title, user_id, start_time, end_time });
      res.status(201).json(dateCourse);
    } catch (error) {
      console.error('Error creating date course:', error);
      res.status(500).json({ error: 'Internal server error' });
    }
  }
);

// 데이 스케줄 조회 (DB)
app.get('/api/date_courses/:user_id', async (req, res) => {
  const userId = req.params.user_id;

  try {
    const dateCourses = await DateCourse.findAll({ where: { user_id: userId } });

    if (dateCourses.length === 0) {
      return res.status(404).json({ error: 'Date courses not found' });
    }

    res.json(dateCourses);
  } catch (error) {
    console.error('Error fetching date courses:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 데이터베이스 동기화 및 서버 실행
sequelize.sync({ force: true }).then(() => {
  console.log('Database synced');
  app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
  });
}).catch(error => {
  console.error('Unable to sync the database:', error);
});
