const Express = require('express');
const BodyParser = require('body-parser');
const CookieParser = require('cookie-parser');

const app = Express();
const ApiRouter = Express.Router();

function isValid(credentials) {
  return !!credentials
    && credentials.userName === 'mycupoftea'
    && credentials.password === 'hunter2';
}

ApiRouter.post('/login', (req, res) => {
  if (isValid(req.body)) {
    res.json({
      firstName: 'Eric',
      lastName: 'Example',
      userName: 'mycupoftea',
      profilePicture: 'http://placekitten.com/400/400',
      age: 30,
    })
  } else {
    res.status(400);
    res.json({ error: 'Invalid username or password' });
  }
});

ApiRouter.post('/logout', (req, res) => {
  res.json({ message: 'Session terminated '});
});

app.use(BodyParser.json());
app.use(CookieParser());
app.use('/', Express.static('dist'));
app.use('/api', ApiRouter);

app.listen(9000);
console.log('Mock server started');
