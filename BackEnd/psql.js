const { Client } = require("pg");

const client = new Client({
  user: "postgres",
  host: "localhost",
  database: "cppick",
  password: "1234",
  port: 5432,
});

client.connect(async (err) => {
  if (err) {
    console.error('Connection error', err.stack);
  } else {
    console.log('Connected to the database');
    
    try {
      // 1. 사용자 생성 (C: Create)
      const createUserQuery = `
        INSERT INTO users (email, username, google_id, kakao_id, naver_id, password_hash)
        VALUES ('test@example.com', 'Test User', 'google123', 'kakao123', 'naver123', 'hashedpassword')
        RETURNING *;
      `;
      const createUserResult = await client.query(createUserQuery);
      console.log('User created:', createUserResult.rows[0]);

      const userId = createUserResult.rows[0].user_id;

      // 2. 사용자 읽기 (R: Read)
      const readUserQuery = "SELECT * FROM users WHERE user_id = $1";
      const readUserResult = await client.query(readUserQuery, [userId]);
      console.log('User details:', readUserResult.rows[0]);

      // 3. 사용자 업데이트 (U: Update)
      const updateUserQuery = `
        UPDATE users SET username = $1 WHERE user_id = $2 RETURNING *;
      `;
      const updateUserResult = await client.query(updateUserQuery, ['Updated User', userId]);
      console.log('User updated:', updateUserResult.rows[0]);

      // 4. 사용자 삭제 (D: Delete)
      const deleteUserQuery = "DELETE FROM users WHERE user_id = $1 RETURNING *";
      const deleteUserResult = await client.query(deleteUserQuery, [userId]);
      console.log('User deleted:', deleteUserResult.rows[0]);

      // 각 테이블 데이터 조회

      // Date Options 테이블 조회
      const dateOptionsResult = await client.query("SELECT * FROM date_options");
      console.log('Date Options:', dateOptionsResult.rows);

      // User Selections 테이블 조회
      const userSelectionsResult = await client.query("SELECT * FROM user_selections");
      console.log('User Selections:', userSelectionsResult.rows);

      // Selection Options 테이블 조회
      const selectionOptionsResult = await client.query("SELECT * FROM selection_options");
      console.log('Selection Options:', selectionOptionsResult.rows);

      // Recommended Courses 테이블 조회
      const recommendedCoursesResult = await client.query("SELECT * FROM recommended_courses");
      console.log('Recommended Courses:', recommendedCoursesResult.rows);

      // Categories 테이블 조회
      const categoriesResult = await client.query("SELECT * FROM categories");
      console.log('Categories:', categoriesResult.rows);

      // Events 테이블 조회
      const eventsResult = await client.query("SELECT * FROM events");
      console.log('Events:', eventsResult.rows);

      // Social Logins 테이블 조회
      const socialLoginsResult = await client.query("SELECT * FROM social_logins");
      console.log('Social Logins:', socialLoginsResult.rows);

      // Date Courses 테이블 조회
      const dateCoursesResult = await client.query("SELECT * FROM date_courses");
      console.log('Date Courses:', dateCoursesResult.rows);

      // Course Categories 테이블 조회
      const courseCategoriesResult = await client.query("SELECT * FROM course_categories");
      console.log('Course Categories:', courseCategoriesResult.rows);

      // MBTI Types 테이블 조회
      const mbtiTypesResult = await client.query("SELECT * FROM mbti_types");
      console.log('MBTI Types:', mbtiTypesResult.rows);

      // Course MBTI 테이블 조회
      const courseMbtiResult = await client.query("SELECT * FROM course_mbti");
      console.log('Course MBTI:', courseMbtiResult.rows);

      // User Preferences 테이블 조회
      const userPreferencesResult = await client.query("SELECT * FROM user_preferences");
      console.log('User Preferences:', userPreferencesResult.rows);

      // MBTI Profiles 테이블 조회
      const mbtiProfilesResult = await client.query("SELECT * FROM mbti_profiles");
      console.log('MBTI Profiles:', mbtiProfilesResult.rows);

      // User Profiles 테이블 조회
      const userProfilesResult = await client.query("SELECT * FROM user_profiles");
      console.log('User Profiles:', userProfilesResult.rows);

      // User Courses 테이블 조회
      const userCoursesResult = await client.query("SELECT * FROM user_courses");
      console.log('User Courses:', userCoursesResult.rows);

      // 음식점 테이블 조회
      const restaurantsResult = await client.query("SELECT * FROM 음식점");
      console.log('Restaurants:', restaurantsResult.rows);

      // 카페 테이블 조회
      const cafesResult = await client.query("SELECT * FROM 카페");
      console.log('Cafes:', cafesResult.rows);

      // 술집 테이블 조회
      const barsResult = await client.query("SELECT * FROM 술집");
      console.log('Bars:', barsResult.rows);

      // Push Notifications 테이블 조회
      const pushNotificationsResult = await client.query("SELECT * FROM push_notifications");
      console.log('Push Notifications:', pushNotificationsResult.rows);

    } catch (err) {
      console.error('Query error', err.stack);
    } finally {
      client.end();  // 연결 종료
    }
  }
});
