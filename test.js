const nodemailer = require('nodemailer');
const email = {
    host: "sandbox.smtp.mailtrap.io",
    port: 2525,
    auth: {
      user: "0d597f3bda536e",
      pass: "********8a3e"
    }
};

const send = async (option) => {
    nodemailer.createTransport(email).sendMail(option, (error, info) => {
        if(error) {
            console.log(error);
        } else {
            console.log(info);
            return info.response;
        }
    });
};

let data = {
   from: 'rkdms9428@naver.com',
   to: 'rkdms9428@naver.com',
   subject: '테스트 메일 입니다.',
   text: 'nodejs 한시간만에 끝내보자'
}

send(email_data);